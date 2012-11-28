# Rake task for populating the database with sample users.
namespace :db do
	desc "Fill database with sample data" # db:populate resets the development database
	task :populate => :environment do #ensures that the Rake task has access to the local Rails environment, including the User model (and hence User.create!).
		require 'faker' 
		Rake::Task['db:reset'].invoke
		admin = User.create!(name: "Example User",
							 email: "example@railstutorial.org",
							 password: "foobar",
							 password_confirmation: "foobar")
		admin.toggle!(:admin)
		99.times do |n|
			name = Faker::Name.name
			email = "example-#{n+1}@railstutorial.org"
			password = "password"
			User.create!(:name => name, 
						 :email => email, 
						 :password => password, 
						 :password_confirmation => password)
		end
	end
end