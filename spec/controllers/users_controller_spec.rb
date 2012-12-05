require 'spec_helper'

describe UsersController do
	render_views #have_selector needs the render_views line since it tests the view along with the action.

  describe "GET 'index'" do
    
    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        second = FactoryGirl.create(:user, :email => "another@example.com")
        third = FactoryGirl.create(:user, :email => "another@example.net")

        @users = [@user, second, third] # Three factory users, signing in as the first one.
        30.times do
          @users << FactoryGirl.create(:user)
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end 
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end
      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2", :content => "2") 
        response.should have_selector("a", :href => "/users?page=2", :content => "Next")
      end
    end
  end
 
  describe "GET 'show'" do

    before(:each) do
      @user = FactoryGirl.create(:user) #@user will simulate an instance of User
    end

    it "shpuld be successful" do
      get :show, :id => @user #get 'show' and get :show do the same thing
      response.should be_success 
    end

    it "should find the right user" do
      get :show, :id => @user #using @user.id would accomplish the same thing, but in this context Rails automatically converts the user object to the corresponding id (by calling the "to_param" method on the @user variable)
      assigns(:user).should == @user #facility provided by RSpec. It takes in a symbol argument and returns the value of the corresponding 'instance' variable in the controller action. In other words, "assigns(:user)" returns the value of the instance variable "@user" in the "show" action of the Users controller.
      #This test verifies that the variable retrieved from the DB in the action corresponds to the @user instance created by Factory Girl.
    end


    #have_selector verifies the presence of a title and h1 tags containing the user's name.
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name) 
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    #"h1>img" makes sure that the img tag is "inside" the h1 tag.
    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar") #to test the CSS class of the element in question.
    end

    it "should show the user's microposts" do
      mp1 = FactoryGirl.create(:micropost, :user => @user, :content => "Foo bar")
      mp2 = FactoryGirl.create(:micropost, :user => @user, :content => "Baz quux")
      get :show, :id => @user
      response.should have_selector("span.content", :content => mp1.content)
      response.should have_selector("span.content", :content => mp2.content)
    end

    it "should display the micropost count" do
      10.times{ FactoryGirl.create(:micropost, :user => @user, :content => "foo") }
      get :show, :id => @user
      response.should have_selector("td.sidebar", :content => @user.microposts.count.to_s)
    end

    it "should paginate microposts" do
      35.times{ FactoryGirl.create(:micropost, :user => @user, :content => "foo") }
      get :show, :id => @user
      response.should have_selector('div.pagination')
    end

    it "should not have delete link for microposts not created by the current user" do
      other_user = FactoryGirl.create(:user)
      test_sign_in(@user)
      get :show, :id => other_user
      response.should_not have_selector("a", :content => "delete")
    end
  end

  describe "GET 'new'" do

    describe "for signed-in users" do

      it "should redirect to the root URL if signed-in user" do
        @user = FactoryGirl.create(:user)
        test_sign_in(@user)
        get :new 
        flash[:notice].should =~ /already/
        response.should redirect_to(root_path)
      end
    end

    it "returns http success" do
      get :new
      response.should be_success
    end
    it "should have the right title" do
    	get :new
    	response.should have_selector("title", :content => "Sign up")
    end
    it "should have a name field" do
       get :new
       response.should have_selector("input[name='user[name]'][type='text']")
    end    
    it "should have an email field" do
       get :new
       response.should have_selector("input[name='user[email]'][type='text']")
    end
    it "should have a password field" do
       get :new
       response.should have_selector("input[name='user[password]'][type='password']")
    end
    it "should have a password confirmation field" do
       get :new
       response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end
  end

  describe "POST 'create'" do

    describe "for signed-in users" do

      it "should redirect to the root URL if signed-in user" do
        @user = FactoryGirl.create(:user)
        test_sign_in(@user)
        post :create,  :id => @user
        flash[:notice].should =~ /already/
        response.should redirect_to(root_path)
      end
    end

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => ""}
      end

      it "should not create a user" do #verify that a failed create action doesn’t create a user in the database
        lambda do #to wrap the post :create step in a package using a Ruby construct called a lambda, which allows us to check that it doesn’t change the User count
          post :create, :user => @attr
        end.should_not change(User, :count) #change method to return the number of users in the database
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector('title', :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new') 
      end
    end

    describe "success" do
      
      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com", :password => "foobar", :password_confirmation => "foobar"}
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr # we use 'post :create' to hit the create action with an HTTP POST request
        end.should change(User, :count).by(1) #asserts that the lambda block should change the User count by 1.
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user))) #(user_path(@user))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to the sample app/i #“equals-tilde” =~ operator for comparing strings to regular expressions. i is for a case-insensitive match
      end

      #for new users so that they are automatically signed in
      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in 
      end

    end
  end

  describe "GET 'edit'" do
    before(:each) do
       @user = FactoryGirl.create(:user)
       test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url, :content => "change") 
    end
  end

  describe "PUT 'update'" do
    
    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    describe "failure" do
      before(:each) do
        @attr = { :email => "", :name => "", :password => "", :password_confirmation => ""}
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
    end

    describe "success" do
      
      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org", :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email] 

        #This code reloads the @user variable from the (test) database using @user.reload, and then verifies that the user’s new name and email match the attributes in the @attr hash.
      end


      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do 
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/ 
      end
    end
  end

  describe "authentication of edit/update pages" do
    
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user 
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {} 
        response.should redirect_to (signin_path)
      end
    end

    describe "for signed-in users" do
      
      before(:each) do
        wrong_user = FactoryGirl.create(:user, :email => "user@example.net") 
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
         get :edit, :id => @user
         response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path) 
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do
      
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        test_sign_in(@admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end

      it "should not be able to destroy itself" do
        lambda do
          delete :destroy, :id => @admin
          flash[:error].should =~ /yourself/
          response.should redirect_to(users_path)
        end.should_not change(User, :count).by(-1)
      end
    end
  end

  describe "follow pages" do

    describe "when not signed-in" do

      it "should protect 'following'" do
        get :following, :id => 1
        response.should redirect_to(signin_path)
      end

      it "should protect 'followers'" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end

    describe "when signed in" do

      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        @other_user = FactoryGirl.create(:user)
        @user.follow!(@other_user)
      end

      it "should show user following" do
        get :following, :id => @user
        response.should have_selector("a", :href => user_path(@other_user), :content => @other_user.name)
      end

      it "should show user followers" do
        get :followers, :id => @other_user
        response.should have_selector("a", :href => user_path(@user), :content => @user.name)
      end
    end
  end
end
