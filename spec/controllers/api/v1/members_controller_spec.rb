require 'rails_helper'

RSpec.describe Api::V1::MembersController, type: :controller do
	before(:each) { request.headers['Accept'] = "application/vnd.marketplace.v1" }

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

end
