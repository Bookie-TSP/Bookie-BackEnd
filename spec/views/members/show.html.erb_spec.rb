require 'rails_helper'

RSpec.describe "members/show", type: :view do
  before(:each) do
    @member = assign(:member, Member.create!(
      :email => "Email",
      :password => "Password",
      :first_name => "First Name",
      :last_name => "Last Name",
      :phnoe_number => "Phnoe Number",
      :identification_number => "Identification Number",
      :gender => "Gender",
      :birth_date => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Password/)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/Phnoe Number/)
    expect(rendered).to match(/Identification Number/)
    expect(rendered).to match(/Gender/)
    expect(rendered).to match(//)
  end
end
