class PagesController < ApplicationController
  def home
  	@title = "Home" # @ means it's an instance variable
  end

  def contact
  	@title = "Contact"
  end

  def about
  	@title = "About"
  end
end
