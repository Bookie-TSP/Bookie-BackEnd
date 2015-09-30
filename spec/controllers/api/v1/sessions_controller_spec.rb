require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
	describe "POST #create" do

  	before(:each) do
  		@member = FactoryGirl.create :member
  	end

  	context "when the credentials are correct" do

  	  before(:each) do
  	    credentials = { email: @member.email, password: "12345678" }
  	    post :create, { session: credentials }
  	  end

  	  it "returns the user record corresponding to the given credentials" do
  	    @member.reload
  	    expect(JSON.parse(response.body, symbolize_names: true)[:auth_token]).to eql @member.auth_token
  	  end

	    it { should respond_with 200 }
	  end

  	context "when the credentials are incorrect" do

  	  before(:each) do
  	    credentials = { email: @member.email, password: "invalidpassword" }
  	    post :create, { session: credentials }
  	  end

    	it "returns a json with an error" do
    	  expect(JSON.parse(response.body, symbolize_names: true)[:errors]).to eql "Invalid email or password"
    	end

   		it { should respond_with 422 }
  	end
	end

	describe "DELETE #destroy" do

    before(:each) do
      @member = FactoryGirl.create :member
      sign_in @member
      delete :destroy, id: @member.auth_token
    end

    it { should respond_with 204 }

  end
end
