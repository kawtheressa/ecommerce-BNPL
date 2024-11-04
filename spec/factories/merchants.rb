# spec/factories/merchants.rb
FactoryBot.define do
  factory :merchant do
    reference { "merchant_#{SecureRandom.hex(4)}" }
    email { "merchant@example.com" }
    live_on { Date.today - 1.year }
    disbursement_frequency { "daily" }
    minimum_monthly_fee { 29.0 }

    trait :weekly do
      disbursement_frequency { "weekly" }
    end
  end
end
