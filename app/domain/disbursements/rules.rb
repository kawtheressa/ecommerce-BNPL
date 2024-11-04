# app/domains/disbursements/rules.rb
module Disbursements
  module Rules
    # Calculate the commission fee percentage based on order amount
    def self.fee_percentage(order_amount)
      if order_amount < 50
        0.01    # 1.00% for orders below 50 €
      elsif order_amount <= 300
        0.0095  # 0.95% for orders between 50 € and 300 €
      else
        0.0085  # 0.85% for orders above 300 €
      end
    end
  end
end
