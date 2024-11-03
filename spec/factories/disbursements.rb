# spec/factories/disbursements.rb
FactoryBot.define do
  factory :disbursement do
    association :merchant  # Creates an associated merchant automatically
    unique_reference { SecureRandom.hex(10) } # Generates a unique reference
    total_amount { 1000.0 }
    commission_fee { 50.0 }
    disbursed_at { DateTime.now }
  end
end
