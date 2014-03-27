FactoryGirl.define do
  factory :shopping_list do
    name 'bob'
    aggregator  '{"a":"bla"}'
    ingredients '{"a":"bla"}'
    user
  end
end

