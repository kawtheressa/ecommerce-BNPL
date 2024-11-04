# spec/factories/disbursements.rb
FactoryBot.define do
  factory :disbursement do
    association :merchant
    unique_reference { SecureRandom.hex(10) }
    total_amount { 1000.0 }
    commission_fee { 50.0 }
    disbursed_at { DateTime.now }
  end
end
