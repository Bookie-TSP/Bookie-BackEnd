require 'rails_helper'

RSpec.describe Member, type: :model do
  before { @member = FactoryGirl.build(:member) }

  subject { @member }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should be_valid }
end
