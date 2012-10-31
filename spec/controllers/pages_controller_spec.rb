#require 'spec_helper'
require_relative '../spec_helper'

describe PagesController do

  describe "GET 'home'" do
    it "returns http success" do
      get 'home'
      response.should be_success
    end
  end

  describe "GET 'contact'" do
    it "returns http success" do
      get 'contact'
      response.should be_success #be_success = status code 200
    end
  end

end
