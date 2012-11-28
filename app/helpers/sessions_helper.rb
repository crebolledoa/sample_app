module SessionsHelper

	def sign_in(user)
		# Array on the right-hand side consists of a unique identifier (i.e. the user's id) and a secure value used to create a digital signature to prevent attacks.
		# Using 'permanent' causes Rails to set the expiration to 20.years.from_now
		# 'signed' makes the cookie secure, so that the user's id is never exposed in the browser.
		
		#cookies.permanent.signed[:remember_token] = [user.id, user.salt]
		
		# The purpose of the following line is to create current_user, accessible in both controllers and views, which will allow constructions such as <%= current_user.name %> and redirect_to current_user.
		
		#current_user = user

		session[:user_id] = user.id
		current_user = user

	end

	def current_user=(user)
		@current_user = user
	end

	def current_user
		# The constructor calls the user_from_remember_token method the first time current_user is called, but on subsequent invocations returns @current_user without calling user_from_remember_token
		
		#@current_user ||= user_from_remember_token 

		# Same as @current_user = @current_user || user_from_remember_token

		@current_user ||= User.find(session[:user_id]) if session[:user_id]
		rescue ActiveRecord::RecordNotFound

	end

	def signed_in?
		!current_user.nil?
	end

	def sign_out
		#cookies.delete(:remember_token)
		#current_user = nil

		session[:user_id] = nil
		current_user = nil

	end

	def current_user?(user)
		user == current_user	
	end
	def deny_access
		# The store_location method puts the requested URL in the session variable under the key :return_to. 
		store_location
		redirect_to signin_path, :notice => "Please sign in to access this page."
		# Shortcut for setting flash[:notice] by passing an options hash to the redirect_to function
		# That's the same as:
		# => flash[:notice] = "Please sign in to access this page."
		# => redirect_to signin_path
		# (The same construction works for the :error key, but not for :success.)
	end

	def redirect_back_or(default)
		# redirect to the requested URL if it exists, or some default URL otherwise. This method is needed in the Sessions controller create action to redirect after successful signin.
		redirect_to(session[:return_to] || default)
		clear_return_to
	end

	private 
		# We’ve made both store_location and clear_return_to private methods since they are never needed outside the Sessions helper.)
		def store_location
			session[:return_to] = request.fullpath
		end
		def clear_return_to
			session[:return_to] = nil
		end

#		def user_from_remember_token
#			User.authenticate_with_salt(*remember_token)
#		end
#		def remember_token
#			cookies.signed[:remember_token] || [nil, nil] 
# We use the || operator to return an array of nil values if cookies.signed[:remember_me] itself is nil. The nil array is used to prevent causing spurious test breakage.
#		end
end

# The * operator allows us to use a two-element array as an argument to a method expecting two variables. 
# cookies.signed[:remember_me] returns an array of two elements, but we want the 'authenticate_with_salt' method to take two arguments, so that it can be invoked with 'User.authenticate_with_salt(id, salt)'


# Each element in the cookie is itself a hash of two elements, a value and an optional expires date.
# For example, we could implement user signin by placing a cookie with value equal to the user’s id that expires 20 years from now:
#	cookies[:remember_token] = { :value => user.id, :expires => 20.years.from_now.utc }
# We could then retrieve the user with code like 
# 	User.find_by_id(cookies[:remember_token])