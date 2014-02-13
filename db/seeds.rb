# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

SuperAdmin.create(first_name: "Kalpesh", last_name: "Fulpagare", email: "admin@example.com", password: "kalpesh1234") if SuperAdmin.count == 0