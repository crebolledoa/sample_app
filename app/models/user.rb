# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean          default(FALSE)
#

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'digest'

class User < ActiveRecord::Base

	attr_accessor :password #virtual password attribute
	attr_accessible :email, :name, :password, :password_confirmation #useful for preventing a mass assigment vulnerability

	has_many :microposts, :dependent => :destroy

	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i


	validates :name, :presence => true,
					 :length => {:maximum => 50 }

	validates :email, :presence => true,
					  :format => { :with => email_regex},
					  :uniqueness => { :case_sensitive => false} #Rails infers that :uniqueness should be true.

	# Automatically create the virtual attribute "password_confirmation"
	validates :password, :presence => true,
						 :confirmation => true,
						 :length => {:within => 6..40}

	before_save :encrypt_password #this is a callback, which delegates the actual encryption to an encrypt method.



	def feed
		# # This is preliminary. See Chapter 12 for the full implementation.

		# The question mark ensures that id is properly escaped before being included in the underlying SQL query, thereby avoiding a serious security hole called SQL injection.
		Micropost.where("user_id = ?", id) # this whole line is equivalent to just write 'microposts'
	end

	#Return true if the user's password matches the submitted password.
	def has_password?(submitted_password)
		#Compare encrypted_password with the encrypted version of submitted_password.
		encrypted_password == encrypt(submitted_password)
	end

	def self.authenticate(email, submitted_password)
		user = find_by_email(email) #invalid email
		return nil if user.nil?
		return user if user.has_password?(submitted_password) #successful match
		#If password mismatch, it will automatically return nil.
	end

	def self.authenticate_with_salt(id, cookie_salt)
		user = find_by_id(id)
		(user && user.salt == cookie_salt)? user : nil # Here it verifies that the salt stored in the cookie is the correct one for that user.
	end


	#EXERCISE 7.5.1: Copy each of the variants of the authenticate method from Listing 7.27 through Listing 7.31 into your User model, and verify that they are correct by running your test suite.

	#Listing 7.27 The authenticate method with User in place of self.
	def User.authenticate(email, submitted_password)
		user = find_by_email(email)
		return nil if user.nil?
		return user if user.has_password?(submitted_password)
	end
	#Listing 7.28 The authenticate method with an explicit third return.
	def self.authenticate(email, submitted_password)
		user = find_by_email(email)
		return nil if user.nil?
		return user if user.has_password?(submitted_password)
		return nil
	end
	#Listing 7.29 The authenticate method using an if statement.
	def self.authenticate(email, submitted_password)
		user = find_by_email(email)
		if user.nil?
			nil
		elsif user.has_password?(submitted_password)
			user
		else
			nil
		end
	end
	#Listing 7.30 The authenticate method using an if statement and an implicit return.
	def self.authenticate(email, submitted_password)
		user = find_by_email(email)
		if user.nil?
			nil
		elsif user.has_password?(submitted_password)
			user
		end
	end
	#Listing 7.31 The authenticate method using the ternary operator.
	def self.authenticate(email, submitted_password)
		user = find_by_email(email)
		user && user.has_password?(submitted_password) ? user : nil
	end


	##################### END OF EXERCISE 7.5.1 #################################



	private

		def encrypt_password #método para encriptar
			self.salt = make_salt if new_record? #assignment to an Active Record attribute
			self.encrypted_password = encrypt(password) #self refers to the object itself, which for the User model is just the user.
		end

		def encrypt(string) #método que encripta un string
			secure_hash("#{salt}--#{string}") #omission of the self keyword in the encrypt method
		end

		def make_salt
			secure_hash("#{Time.now.utc}--#{password}")
		end

		def secure_hash(string)
			Digest::SHA2.hexdigest(string)
		end

end
