# app/domains/merchants/merchant.rb
module Merchants
  class Merchant
    attr_reader :reference, :email, :live_on, :disbursement_frequency, :minimum_monthly_fee

    def initialize(reference:, email:, live_on:, disbursement_frequency:, minimum_monthly_fee:)
      @reference = reference
      @email = email
      @live_on = live_on
      @disbursement_frequency = disbursement_frequency
      @minimum_monthly_fee = minimum_monthly_fee
    end
  end
end
