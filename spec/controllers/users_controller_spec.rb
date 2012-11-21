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
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
    	get 'new'
    	response.should have_selector("title", :content => "Sign up")
    end
  end
end
