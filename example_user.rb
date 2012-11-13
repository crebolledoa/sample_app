class User
	attr_accessor :name, :email #creates attribute accessors 
	#(corresponding to a user's name and email address).
	#This creates "getter" and "setter" methods that allow us to 
	#retrieve (get) and assign (set) @name and @email instance variables

	def initialize(attributes = {}) #method called when we execute
		#User.new. The attributes variable has a default value equal 
		#to the empty hash; we can define a user with no name or email.
		#(attributes[:name] will be nil if there's no :name key, and
		#similarly for attributes[:email]).
		@name = attributes[:name]
		@email = attributes[:email]
	end
	
	def formatted_email #uses the values of the assigned @name and 
		#@email variables to build up a nicely formatted version of 
		#the user's email address using string interpolation.
		"#{@name} <#{@email}>"
	end

end