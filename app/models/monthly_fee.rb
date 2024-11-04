# app/models/monthly_fee.rb
class MonthlyFee < ApplicationRecord
  belongs_to :merchant

  validates :fee_month, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
