class UsersController < ApplicationController
  
  def show
  	@user = User.find(params[:id])
  	@title = @user.name
  end

  def new
  	@user = User.new
  	@title = "Sign up"
  end

  def create
  	@user = User.new(params[:user]) #this is equivalent to: @user = User.new(:name => "Foo Bar", :email => "foo@invalid",:password => "dude", :password_confirmation => "dude")
  	if @user.save
      sign_in @user
  		flash[:success] = "Welcome to the Sample App!"
  		redirect_to user_path(@user)
  	else
  		@title = "Sign up"
  		render 'new'
  		@user.password = "" #clear the password field for failed submissions
  	end 
  end
end
