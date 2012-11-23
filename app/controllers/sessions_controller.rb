class SessionsController < ApplicationController
  def new
  	@title = "Sign in"
  end
  def create
  	# user = User.authenticate. 	#if user.nil? Create error msg and re-render the signin form   	#else, sign the user in and redirect to the user's show page
  	user = User.authenticate(params[:session][:email],
  							 params[:session][:password])
  	if user.nil?
  		#The flash.now object is specifically designed for displaying flash messages on rendered pages.
  		flash.now[:error] = "Invalid email/password combination."
  		@title = "Sign in"
  		render 'new'
  	else
  		#Sign the user in and redirect to the user's show page
  		sign_in user
  		redirect_to user
  	end
  end
  def destroy
  	 sign_out
     redirect_to root_path
  end
end


# :params[:session] is itself a hash: 

#	{ :password => "", :email => ""}

#	As a result, 
#		params[:session][:email] is the submitted email address, and
#		params[:session][:passwrod] is the submitted password.

#Inside the create action, the params hash has all the information neded to authenticate users by email and password.


#The flash variable is designed to be used before a redirect, and it persists on the resulting page for one request---that is, it ppears once, and disappears when you click on another link. Unfortunately, this means that if we don’t redirect, and instead simply render a page (as in Listing 9.8), the flash message persists for two requests: it appears on the rendered page but is still waiting for a ‘‘redirect’’ (i.e., a second request), and thus appears again if you click a link.