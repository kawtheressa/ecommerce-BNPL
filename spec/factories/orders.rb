# spec/factories/orders.rb
FactoryBot.define do
  factory :order do
    association :merchant  # Creates an associated merchant automatically
    amount { 100.50 } # Default amount
  end
end
