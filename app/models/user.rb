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