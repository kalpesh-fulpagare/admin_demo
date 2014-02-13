# Admin demo
Sample ruby on rails app with steps to quickly create a new Ruby on Rails app with two Admin types(SuperAdmin and Admin). Admin panel UI is built using twitter bootstrap plugin

## Steps
#### Environment Information
`ruby - 2.1.0`
`rails 4.0.2`
`devise 3.2.2`
`twitter-bootstrap 2.3.2`
#### Create new Rails app with mysql database, skip test cases

```
rails new admin_demo -T -d=mysql
```

#### Add required gems devise

```
gem 'devise'
gem 'inherited_resources'
group :development, :test do
  gem 'debugger'
end
```

#### Run bundle to install the gems
```
bundle
```

#### Run the bootstrap generator to bootstrap assets
```
rails generate bootstrap:install static
```

#### Generate separate bootstrap layout for admins
I am going to use separate layout for SuperAdmin and Admin
<br>
PS: In this example I am going to use **SuperAdmin** and **Restaurant** as resource names

```
rails g bootstrap:layout super_admin fixed
rails g bootstrap:layout restaurants fixed
```
#### Now generate our admin model
PS: In this example I have used **Single Table Inheritance**, i.e. same admin model for both admin
Inherited model names are **SuperAdmin** and **Restaurant**

```
rails g model Admin type:string first_name:string last_name:string
```
PS: *type* column is added for **STI**

#### Generate devise configuration file
```
rails generate devise:install
```
It will generate **devise.rb** configuration file in config/initializers and **devise.en.yml** in config/locales

#### Add host name to your environment files
```ruby
# config\environments\development.rb
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
# config\environments\test.rb
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
# config\environments\production.rb
config.action_mailer.default_url_options = { :host => 'ACTUAL PRODUCTION HOST' }
```

#### Generate devise migration
```
rails generate devise Admin
```
It will generate *change migration* which will add columns in admin table.
<br>
It will also add **devise_for :admins** in routes.rb. Delete this line as we will be using devise for SuperAdmin and Restaurant model. We will create these models in next step.
<br>
It will also add following lines in admin model(admin.rb).
```ruby
#Include default devise modules. Others available are:
#:confirmable, :lockable, :timeoutable and :omniauthable
devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
```
Remove these lines as well from **admin.rb**

#### Create models for SuperAdmin and Admin
i.e. creating super_admin and restaurant model
```
touch app/models/super_admin.rb
touch app/models/restaurant.rb
```

#### Include devise module in these models
###### Also inherit these models from Admin instead of ActiveRecord::Base
**restaurant.rb**
```ruby
class Restaurant < Admin
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
```
**super_admin.rb**
```ruby
class SuperAdmin < Admin
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
```
#### Generating devise routes
```ruby
devise_for :restaurants
devise_for :super_admins
```
it will create routes like
```
/restaurants/sign_in
/super_admins/sign_in
```
`super_admins` does not sounds good to me, so I changed the path name for super_admins as follows
<br>
Its personal choice if you want to change any of them, or want to keep as it is.
<br>
You can change it as follows.

```ruby
devise_for :restaurants
devise_for :super_admins, path: "super_admin"
```
so it will generate routes like this
```
/restaurants/sign_in
/super_admin/sign_in
```
#### Create dashboard
We will need a page for root url.
I have created dashboard controller in this example.
```
rails g controller dashboard
```
I have added index action in this controller
```ruby
class DashboardController < ApplicationController

  def index
  end

end

```
#### Create view file for controller
```
$ cat > app/views/dashboard/index.html.erb
Hi
This is Home page of your app
# Press 'Control + D' to tell the Linux OS that what is typed is to be stored into the file
```

#### Now add this dashboard#index action as root url in routes.rb
```ruby
root 'dashboard#index'
```

#### Adding default super admin account for login
add this in **db/seeds.rb**
```ruby
if SuperAdmin.count == 0
  SuperAdmin.create(first_name: "Super", last_name: "Admin", email: "superadmin@example.com", password: "superadmin123")
  puts "SuperAdmin account created\nCredentials: superadmin@example.com/superadmin123"
else
  puts "SuperAdmin account already exists, skipping SuperAdmin creation"
end
```
Run seed file using <br>
`rake db:seed`

#### Test account for restaurant
```ruby
if Restaurant.count == 0
  Restaurant.create(first_name: "Restaurant", last_name: "Admin", email: "restaurant@example.com", password: "restaurant123")
  puts "Restaurant account created\nCredentials: restaurant@example.com/restaurant123"
end # optional - if you want a restaurant account to test your changes
```

#### Creating parent controller for our super_admin and restaurant modules
It will be good if we create a super_admin and restaurants controller and inherit all controller of super_admin module from super_admin_controller and restaurant modules from restaurants_controller.
in this way we have to apply our helper methods(authenticate_restaurant and authenticate_super_admin) in these controllers only. Same applies for layout as well.

```ruby
$ cat > app/controllers/super_admin_controller.rb
class SuperAdminController < ApplicationController
  layout 'super_admin'
  before_action :authenticate_super_admin!
end  # After typing end press 'Control + D' to save file

$ cat > app/controllers/restaurants_controller.rb
class RestaurantsController < ApplicationController
  layout 'restaurants'
  before_action :authenticate_restaurant!
end
```

#### We need a dashboard for both restaurants and super_admin, lets create one
Here I have kept every controller related to SuperAdmin in **super_admin** namespace
and restarant's controllers in **restaurants** namespace.

```ruby
$ mkdir app/controllers/super_admin
$ cat > app/controllers/super_admin/dashboard_controller.rb
class SuperAdmin::DashboardController < SuperAdminController
  def index
  end
end # After typing end press 'Control + D' to save file
$ mkdir app/views/super_admin
$ mkdir app/views/super_admin/dashboard
$ cat > app/views/super_admin/dashboard/index.html.erb
This is SuperAdmin dashboard  # press 'Control + D' to save file


$ mkdir app/controllers/restaurants
$ cat > app/controllers/restaurants/dashboard_controller.rb
class Restaurants::DashboardController < RestaurantsController
  def index
  end
end # After typing end press 'Control + D' to save file
$ mkdir app/views/restaurants
$ mkdir app/views/restaurants/dashboard
$ cat > app/views/restaurants/dashboard/index.html.erb
This is Restaurant dashboard  # press 'Control + D' to save file
```

#### Also add dashboard resource in super_admin and restaurants namespace
```ruby
namespace :restaurants do
  resources :dashboard, only: [:index]
end

namespace :super_admin do
  resources :dashboard, only: [:index]
end
```

#### Now override sessions controller
Need to override sessions controller to set custom path after signing in and signing out.
modify routes.rb
```ruby
devise_for :restaurants, controllers: { sessions: "restaurants/sessions" }
devise_for :super_admins, path: "super_admin", controllers: { sessions: "super_admin/sessions" }
```

#### Create sessions controllers
cat > app/controllers/restaurants/sessions_controller.rb
```ruby
class Restaurants::SessionsController < Devise::SessionsController
  layout "restaurants"

  private
    def after_sign_in_path_for(resource)
      session[:restaurant_return_to].blank? ? restaurants_dashboard_index_path : session[:restaurant_return_to]
    end

    def after_sign_out_path_for(resource_or_scope)
      new_restaurant_session_path
    end
end # Save using 'Control + D'
````
<br>
cat > app/controllers/super_admin/sessions_controller.rb
````ruby
class SuperAdmin::SessionsController < Devise::SessionsController
  layout "super_admin"

  private
    def after_sign_in_path_for(resource)
      session[:super_admin_return_to].blank? ? super_admin_dashboard_index_path : session[:super_admin_return_to]
    end

    def after_sign_out_path_for(resource_or_scope)
      new_super_admin_session_path
    end
end # Save using 'Control + D'
```
###### Now you will be able to login using super_admin and restaurant account and will be able to see your dashboard

#### We need link for logout
change layout file as follows

**layouts/super_admin.html.erb**
<br>
Replace
```xml
<ul class="nav">
  <li><%= link_to "Link1", "/path1"  %></li>
  <li><%= link_to "Link2", "/path2"  %></li>
  <li><%= link_to "Link3", "/path3"  %></li>
</ul>

```
With
```ruby
<%- if current_super_admin %>
  <ul class="nav">
    <li><%= link_to "Dashboard", "/super_admin/dashboard" %></li>
  </ul>
  <ul class="nav pull-right">
    <li class="dropdown">
      <a href="#" class="dropdown-toggle" data-toggle="dropdown">
        <%= current_super_admin.email %> <b class="caret"></b>
      </a>
      <ul class="dropdown-menu">
        <li><%= link_to "Logout", destroy_super_admin_session_path, method: "DELETE"  %></li>
      </ul>
    </li>
  </ul>
<% end %>
```
<br><br>
**layouts/restaurants.html.erb**
<br>
Replace
```xml
<ul class="nav">
  <li><%= link_to "Link1", "/path1"  %></li>
  <li><%= link_to "Link2", "/path2"  %></li>
  <li><%= link_to "Link3", "/path3"  %></li>
</ul>

```
With
```ruby
<%- if current_restaurant %>
  <ul class="nav">
    <li><%= link_to "Dashboard", "/restaurants/dashboard" %></li>
  </ul>
  <ul class="nav pull-right">
    <li class="dropdown">
      <a href="#" class="dropdown-toggle" data-toggle="dropdown">
        <%= current_restaurant.email %> <b class="caret"></b>
      </a>
      <ul class="dropdown-menu">
        <li><%= link_to "Logout", destroy_restaurant_session_path, method: "DELETE"  %></li>
      </ul>
    </li>
  </ul>
<% end %>
```

#### To customize devise views
inside **config/initializers/devise.rb**
<br>
add `config.scoped_views = true`
<br>
And generate views
```
$ rails generate devise:views super_admin
$ rails generate devise:views restaurants
```
