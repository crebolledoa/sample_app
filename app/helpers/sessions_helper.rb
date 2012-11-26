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

	private

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