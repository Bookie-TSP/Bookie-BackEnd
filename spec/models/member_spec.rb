require 'rails_helper'

RSpec.describe Member, type: :model do
  before { @member = FactoryGirl.build(:member) }

  subject { @member }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:auth_token) }


  it { should be_valid }

  describe "when email is not present" do
  	before { @member.email = " " }
  	it { should_not be_valid }
	end

	it { should validate_presence_of(:email) }
	it { should validate_uniqueness_of(:email) }
	it { should validate_confirmation_of(:password) }
	it { should allow_value('example@domain.com').for(:email) }
  it { should validate_uniqueness_of(:auth_token)}

  it { should validate_uniqueness_of(:auth_token)}

  describe "#generate_authentication_token!" do
    it "generates a unique token" do
      Devise.stub(:friendly_token).and_return("auniquetoken123")
      @member.generate_authentication_token!
      expect(@member.auth_token).to eql "auniquetoken123"
    end

    it "generates another token when one already has been taken" do
      existing_member = FactoryGirl.create(:member, auth_token: "auniquetoken123")
      @member.generate_authentication_token!
      expect(@member.auth_token).not_to eql existing_member.auth_token
    end
  end

end
