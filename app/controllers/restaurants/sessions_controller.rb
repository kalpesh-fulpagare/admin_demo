class Restaurants::SessionsController < Devise::SessionsController

  private
    def after_sign_in_path_for(resource)
      session[:restaurant_return_to].blank? ? restaurants_dashboard_index_path : session[:restaurant_return_to]
    end

    def after_sign_out_path_for(resource_or_scope)
      new_restaurant_session_path
    end
end
