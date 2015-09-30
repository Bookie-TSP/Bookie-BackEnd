require 'rails_helper'

RSpec.describe Member, type: :model do
  before { @member = FactoryGirl.build(:member) }

  subject { @member }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should be_valid }

  describe "when email is not present" do
  	before { @member.email = " " }
  	it { should_not be_valid }
	end

	it { should validate_presence_of(:email) }
	it { should validate_uniqueness_of(:email) }
	it { should validate_confirmation_of(:password) }
	it { should allow_value('example@domain.com').for(:email) }
end
