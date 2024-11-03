# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement, optional: true # `optional: true` if we create orders before disbursements are assigned

  validates :amount, presence: true
end
