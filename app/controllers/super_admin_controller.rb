class SuperAdminController < ApplicationController
  layout 'super_admin'
  before_action :authenticate_super_admin!
end
