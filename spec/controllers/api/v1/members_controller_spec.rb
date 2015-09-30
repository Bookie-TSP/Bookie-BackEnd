require 'rails_helper'

RSpec.describe Api::V1::MembersController, type: :controller do
	before(:each) { request.headers['Accept'] = "application/vnd.marketplace.v1" }
  before(:each) { request.headers['Content-Type'] = Mime::JSON.to_s }
  
  describe "GET #show" do
    before(:each) do
      @member = FactoryGirl.create :member
      get :show, id: @member.id, format: :json
    end

    it "returns the information about a reporter on a hash" do
      member_response = JSON.parse(response.body, symbolize_names: true)
      expect(member_response[:email]).to eql @member.email
    end

    it { should respond_with 200 }
  end

  describe "POST #create" do

    context "when is successfully created" do
      before(:each) do
        @member_attributes = FactoryGirl.attributes_for :member
        post :create, { member: @member_attributes }, format: :json
      end

      it "renders the json representation for the user record just created" do
        member_response = JSON.parse(response.body, symbolize_names: true)
        expect(member_response[:email]).to eql @member_attributes[:email]
      end

      it { should respond_with 201 }
    end

    context "when is not created" do
      before(:each) do
        #notice I'm not including the email
        @invalid_member_attributes = { password: "12345678",
                                     password_confirmation: "12345678" }
        post :create, { member: @invalid_member_attributes }, format: :json
      end

      it "renders an errors json" do
        member_response = JSON.parse(response.body, symbolize_names: true)
        expect(member_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not be created" do
        member_response = JSON.parse(response.body, symbolize_names: true)
        expect(member_response[:errors][:email]).to include "can't be blank"
      end

      it { should respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do

    context "when is successfully updated" do
      before(:each) do
        @member = FactoryGirl.create :member
        request.headers['Authorization'] = @member.auth_token
        patch :update, { id: @member.id,
                         member: { email: "newmail@example.com" } }, format: :json
      end

      it "renders the json representation for the updated user" do
        member_response = JSON.parse(response.body, symbolize_names: true)
        expect(member_response[:email]).to eql "newmail@example.com"
      end

      it { should respond_with 200 }
    end

    context "when is not created" do
      before(:each) do
        @member = FactoryGirl.create :member
        request.headers['Authorization'] = @member.auth_token
        patch :update, { id: @member.id,
                         member: { email: "bademail.com" } }, format: :json
      end

      it "renders an errors json" do
        member_response = JSON.parse(response.body, symbolize_names: true)
        expect(member_response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        member_response = JSON.parse(response.body, symbolize_names: true)
        expect(member_response[:errors][:email]).to include "is invalid"
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @member = FactoryGirl.create :member
      request.headers['Authorization'] = @member.auth_token
      delete :destroy, { id: @member.id }, format: :json
    end

    it { should respond_with 204 }
  end

end
