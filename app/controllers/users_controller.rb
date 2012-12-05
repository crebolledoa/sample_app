class UsersController < ApplicationController

  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  #by default, before filters apply to EVERY action in a controller, so here we restrict the filter to act only on the :edit and :update actions by passing the :only options hash.
  
  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
  	@title = @user.name
  end

  def new
    if !signed_in?
    	@user = User.new
    	@title = "Sign up"
    else
      flash[:notice] = "You are already logged in!"
      redirect_to root_path
    end
  end

  def create
    if !signed_in?
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
    else
      flash[:notice] = "You are already logged in!"
      redirect_to root_path
    end
  end

  def edit
    @title = "Edit user" 
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    if current_user?(User.find(params[:id]))
      flash[:error] = "You're destroying yourself, you can't do that!" 
      redirect_to users_path
    else
      User.find(params[:id]).destroy
      flash[:success] = "User destroyed."
      redirect_to users_path
    end
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  private
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end