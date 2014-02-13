# Admin demo
Sample ruby on rails app with steps to quickly create a new Ruby on Rails app with two Admin types(SuperAdmin and Admin). Admin panel UI is built using twitter bootstrap plugin

## Steps
#### Environment Information
`ruby - 2.1.0`
`rails 4.0.2`
`devise 3.2.2`
`twitter-bootstrap 3.1.0`
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

#### Bootstrap assets
Rename application.css to application.css.sass

###### Run following command to import bootstrap css components explicitly
```
cp $(bundle show bootstrap-sass)/vendor/assets/stylesheets/bootstrap.scss \
 app/assets/stylesheets/bootstrap-custom.scss
```
###### change content of application.css.sass to
```
//= require_self
//= require bootstrap-custom
```

#### Generate separate layout for admins
I am going to use separate layout for SuperAdmin and Admin
<br>
PS: In this example I am going to use **SuperAdmin** and **Restaurant** as resource names

```
touch app/views/layouts/super_admin.html.erb
touch app/views/layouts/restaurants.html.erb
```

#### Now generate our admin model
PS: In this example I have used **Single Table Inheritance**, i.e. same admin model for both admins.
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
It will also add **devise_for :admins** in routes.rb.
**Delete** this line as we will be using devise for SuperAdmin and Restaurant model.
<br>
We will create these models in next step.
<br>
Above command will also add following lines in admin model(admin.rb).
```ruby
#Include default devise modules. Others available are:
#:confirmable, :lockable, :timeoutable and :omniauthable
devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
```
Remove these lines as well from **admin.rb**

#### Run migration
Check migration and comment/uncomment columns which are required as per your applications requirement.
<br>
I wanted confirmable module so I uncommented following lines from the migration file

```ruby
## Confirmable
t.string   :confirmation_token
t.datetime :confirmed_at
t.datetime :confirmation_sent_at
t.string   :unconfirmed_email
.
.
.
.
add_index :admins, :confirmation_token,   :unique => true

```
<br>
run migration using `rake db:migrate`
<br>


#### Create models for SuperAdmin and Admin
i.e. creating super_admin and restaurant model
```
touch app/models/super_admin.rb
touch app/models/restaurant.rb
```

#### Include devise modules in these models
###### Also inherit these models from `Admin` instead of `ActiveRecord::Base`
**restaurant.rb** contents
```ruby
class Restaurant < Admin
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
```

**super_admin.rb** contents
```ruby
class SuperAdmin < Admin
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable,
        :rememberable, :trackable, :validatable
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
Its as per personal choice if you want to change any of them, or want to keep as it is.
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
We need a page for our apps root url.
I have created dashboard controller in this app.
```
rails g controller dashboard
```

I have added `index` action in this controller

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
Following lines can be executed in console to create a test account for restaurant model.
```ruby
if Restaurant.count == 0
  Restaurant.create(first_name: "Restaurant", last_name: "Admin", email: "restaurant@example.com", password: "restaurant123")
  puts "Restaurant account created\nCredentials: restaurant@example.com/restaurant123"
end # optional - if you want a restaurant account to test your changes
```

#### Creating parent controller for our super_admin and restaurant modules
Its be good if we create a super_admin and restaurants controller and inherit all controllers of super_admin module from **super_admin_controller** and restaurant modules from **restaurants_controller**.
in this way we have to apply our helper methods(authenticate_restaurant and authenticate_super_admin) in these controllers only. Same applies for layout as well.

```ruby
$ cat > app/controllers/super_admin_controller.rb
class SuperAdminController < ApplicationController
  layout 'super_admin'
  before_action :authenticate_super_admin!
end  # After typing end press 'Control + D' to save contents to file

$ cat > app/controllers/restaurants_controller.rb
class RestaurantsController < ApplicationController
  layout 'restaurants'
  before_action :authenticate_restaurant!
end
```

#### We need a dashboard for both admins(restaurants and super_admin), lets create one for each
Here I have kept every controller related to SuperAdmin in **super_admin** namespace
and restarant's controllers in **restaurants** namespace.

```
$ mkdir app/controllers/super_admin
```
```ruby
cat > app/controllers/super_admin/dashboard_controller.rb
class SuperAdmin::DashboardController < SuperAdminController
  def index
  end
end
# press 'Control + D' to save contents to file
```
```
$ mkdir app/views/super_admin
$ mkdir app/views/super_admin/dashboard
```
```ruby
$ cat > app/views/super_admin/dashboard/index.html.erb
This is SuperAdmin dashboard
# press 'Control + D' to save contents to file
```
```
$ mkdir app/controllers/restaurants
```
```ruby
$ cat > app/controllers/restaurants/dashboard_controller.rb
class Restaurants::DashboardController < RestaurantsController
  def index
  end
end
# press 'Control + D' to save contents to file
```
```
$ mkdir app/views/restaurants
$ mkdir app/views/restaurants/dashboard
```
```ruby
$ cat > app/views/restaurants/dashboard/index.html.erb
This is Restaurant dashboard
# press 'Control + D' to save contents to file
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
end
# press 'Control + D' to save contents to file
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
end
# press 'Control + D' to save contents to file
```

###### Now you will be able to login using super_admin and restaurant account and will be able to see your dashboard


###### Similarly if required, you can override other controllers of devise as well
**Overriding Passwords, confirmations controller**
<br>
cat > app/controllers/super_admin/passwords_controller.rb
```ruby
class SuperAdmin::PasswordsController < Devise::PasswordsController
  layout "super_admin"
end
# press 'Control + D' to save contents to file
```
<br>
cat > app/controllers/super_admin/confirmations_controller.rb
```ruby
class SuperAdmin::ConfirmationsController < Devise::ConfirmationsController
  layout "super_admin"
end
# press 'Control + D' to save contents to file

### routes.rb
devise_for :super_admins, path: "super_admin", controllers: { sessions: "super_admin/sessions", passwords: "super_admin/passwords", confirmations: "super_admin/confirmations" }
```
#### We need link for logout
**layouts/super_admin.html.erb**
<br>
Add following link in layout file for super_admin
``
<%- if current_super_admin %>
  <%= link_to "Logout", destroy_super_admin_session_path, method: "DELETE"  %>
<% end %>
```

**layouts/restaurants.html.erb**
And for restaurant, add this link
```
<%- if current_restaurant %>
  <%= link_to "Logout", destroy_restaurant_session_path, method: "DELETE"  %>
<% end %>
```
###### You can use my layouts files from this branch(bootsrap31) if you are using bootstrap 3.1.0 in your app

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
###### Similarly you can copy my view files. Syntax is as per bootstrap 3.1.0

~Thanks for reading~