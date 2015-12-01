FactoryGirl.define do
  factory :payment do
    order nil
billing_name "MyString"
billing_type "MyString"
billing_card_number "MyString"
billing_card_expire_date "2015-11-18"
billing_card_security_number 1
  end

end
