# app/domains/disbursements/calculator.rb
module Disbursements
  class Calculator
    def initialize(order_amount)
      @order_amount = order_amount
    end

    def calculate_fee
      fee_percentage = Rules.fee_percentage(@order_amount)
      (@order_amount * fee_percentage).round(2)
    end
  end
end
