FactoryGirl.define do
  factory :member do
    email { FFaker::Internet.email }
    password "12345678"
    password_confirmation "12345678"
  end

end
