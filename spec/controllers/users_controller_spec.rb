require 'spec_helper'

describe UsersController do
	render_views #have_selector needs the render_views line since it tests the view along with the action.


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

  end

  describe "GET 'new'" do

    it "returns http success" do
      get :new
      response.should be_success
    end
    it "should have the right title" do
    	get :new
    	response.should have_selector("title", :content => "Sign up")
    end

  end

  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => ""}
      end

      it "should not create a user" do #verify that a failed create action doesn’t create a user in the database
        lambda do #to wrap the post :create step in a package using a Ruby construct called a lambda,2 which allows us to check that it doesn’t change the User count
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
          post: create, :user => @attr # we use 'post :create' to hit the create action with an HTTP POST request
        end.should change(User, :count).by(1) #asserts that the lambda block should change the User count by 1.
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user))) #(user_path(@user))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =˜ /welcome to the sample app/i #“equals-tilde” =~ operator for comparing strings to regular expressions. i is for a case-insensitive match
      end
    end
  end
end
