#'userS_spec', since it's an integration test. 'user_spec' is the user's model test
#This integration test ties together all the different parts of Rails, including models, views, controllers, routing, and helpers. It provides an end-to-end verification that our signup machinery is working, at least for failed submissions.
require 'spec_helper'

describe "Users" do

	describe "signup" do

		describe "failure" do

			it "should not make a new user" do
				lambda do
					visit signup_path
					fill_in "Name", :with => ""	#fill_in :user_name (CSS id of the text box) also works, nice for forms that don't use labels
					fill_in "Email", :with => ""
					fill_in "Password", :with => ""
					fill_in "Confirmation", :with => ""
					click_button
					response.should render_template('users/new')
					response.should have_selector("div#error_explanation") #Here "div#error_explanation" is CSS-inspired shorthand for <div id="error_explanation">...</div>
				end.should_not change(User, :count) #this is what tests that a failed submission fails to create a new user. verifies that the code inside the lambda block doesn’t change the value of User.count.
			end
		end

		describe "success" do
			#testing that successful signup actually creates a user in the database:
			it "should nake a new user" do
				lambda do
					visit signup_path
					fill_in "Name", :with => "Example User"
					fill_in "Email", :with => "user@example.com"
					fill_in "Password", :with => "foobar"
					fill_in "Confirmation", :with => "foobar"
					click_button #the result should be the user show page with a “flash success” div tag, and it should change the User count by 1.
					response.should have_selector("div.flash.success", :content => "Welcome")
					response.should render_template('users/show')
				end.should change(User, :count).by(1) 
			end
		end
	end

	describe "sign in/out" do

		describe "failure" do
			it "should not sign a user in" do
				#integration_sign_in(FactoryGirl.create(:user, :email => "", :password =>""))
				visit signin_path
				fill_in :email, :with => ""
				fill_in :password, :with => ""
				click_button
				response.should have_selector("div.flash.error", :content => "Invalid")
			end
		end
		describe "success" do
			it "should sign a user in and out" do
				integration_sign_in(FactoryGirl.create(:user))
				#user = FactoryGirl.create(:user)
				#visit signin_path
				#fill_in :email, :with => user.email
				#fill_in :password, :with => user.password
				#click_button
				controller.should be_signed_in
				click_link "Sign out"
				controller.should_not be_signed_in
			end
		end
	end
end