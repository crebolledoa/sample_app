module UsersHelper

	def gravatar_for(user, options = { :size => 50}) #sets default gravatar size to 50x50
		#user.email.downcase passes in the lower-case version of the user's email address
		gravatar_image_tag(user.email.downcase, :alt => user.name, #assigns the user's name to the img tag's alt attribute
												:class => "gravatar", #sets the CSS class of the resulting Gravatar
												:gravatar => options) #passes the options hash using :gravatar key, which is how to set the options for gravatar_image_tag
	end

end
