class RestaurantsController < ApplicationController
  layout 'restaurants'
  before_action :authenticate_restaurant!
end