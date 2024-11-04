# spec/factories/monthly_fees.rb
FactoryBot.define do
  factory :monthly_fee do
    association :merchant
    fee_month { Date.today.beginning_of_month } # Default to the current month's beginning
    amount { 50.0 } # Default amount, can be overridden in tests

    trait :high_fee do
      amount { 100.0 } # Custom amount for cases where a high fee is needed
    end

    trait :low_fee do
      amount { 10.0 } # Custom amount for cases where a low fee is needed
    end
  end
end
