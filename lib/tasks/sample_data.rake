require 'faker' 

# Rake task for populating the database with sample users.
namespace :db do
	desc "Fill database with sample data" # db:populate resets the development database
	task :populate => :environment do #ensures that the Rake task has access to the local Rails environment, including the User model (and hence User.create!).
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
		User.all(:limit => 6).each do |user|
			50.times do
				content = Faker::Lorem.sentence(5)
				user.microposts.create!(:content => content)
			end
		end
	end
end