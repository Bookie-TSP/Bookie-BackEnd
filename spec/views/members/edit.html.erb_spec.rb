require 'rails_helper'

RSpec.describe "members/edit", type: :view do
  before(:each) do
    @member = assign(:member, Member.create!(
      :email => "MyString",
      :password => "MyString",
      :first_name => "MyString",
      :last_name => "MyString",
      :phnoe_number => "MyString",
      :identification_number => "MyString",
      :gender => "MyString",
      :birth_date => ""
    ))
  end

  it "renders the edit member form" do
    render

    assert_select "form[action=?][method=?]", member_path(@member), "post" do

      assert_select "input#member_email[name=?]", "member[email]"

      assert_select "input#member_password[name=?]", "member[password]"

      assert_select "input#member_first_name[name=?]", "member[first_name]"

      assert_select "input#member_last_name[name=?]", "member[last_name]"

      assert_select "input#member_phnoe_number[name=?]", "member[phnoe_number]"

      assert_select "input#member_identification_number[name=?]", "member[identification_number]"

      assert_select "input#member_gender[name=?]", "member[gender]"

      assert_select "input#member_birth_date[name=?]", "member[birth_date]"
    end
  end
end
