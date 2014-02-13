module ApplicationHelper
  ALERT_TYPES = [:danger, :info, :success, :warning]

  def html_errors(object)
    errors = ''
    if object.errors.any?
      errors += '<div class="alert fade in alert-danger alert-block"><button class="close" data-dismiss="alert">x</button><strong>Please fix following errors</strong><br>'
      errors +=  object.errors.full_messages.join("<br>")
      errors += "</div>"
    end
    raw errors
  end

  def show_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = :success if type == :notice
      type = :danger   if type == :alert
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           msg.html_safe, :class => "alert fade in alert-#{type}")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end
end
