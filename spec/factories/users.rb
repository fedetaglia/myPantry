FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end
  
  factory :user do
    username 'bob'
    email
    password 'password'
    password_confirmation 'password'
  end
end