# app/models/disbursement.rb
class Disbursement < ApplicationRecord
  has_many :orders
  belongs_to :merchant

  validates :unique_reference, presence: true, uniqueness: true
  validates :total_amount, :commission_fee, :disbursed_at, presence: true
end
