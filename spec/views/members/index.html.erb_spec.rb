require 'rails_helper'

RSpec.describe "members/index", type: :view do
  before(:each) do
    assign(:members, [
      Member.create!(
        :email => "Email",
        :password => "Password",
        :first_name => "First Name",
        :last_name => "Last Name",
        :phnoe_number => "Phnoe Number",
        :identification_number => "Identification Number",
        :gender => "Gender",
        :birth_date => ""
      ),
      Member.create!(
        :email => "Email",
        :password => "Password",
        :first_name => "First Name",
        :last_name => "Last Name",
        :phnoe_number => "Phnoe Number",
        :identification_number => "Identification Number",
        :gender => "Gender",
        :birth_date => ""
      )
    ])
  end

  it "renders a list of members" do
    render
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Password".to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Phnoe Number".to_s, :count => 2
    assert_select "tr>td", :text => "Identification Number".to_s, :count => 2
    assert_select "tr>td", :text => "Gender".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
