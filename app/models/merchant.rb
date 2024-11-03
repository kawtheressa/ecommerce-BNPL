class Merchant < ApplicationRecord
  has_many :orders
  has_many :disbursements

  validates :reference, :email, :live_on, :disbursement_frequency, :minimum_monthly_fee, presence: true

  enum :disbursement_frequency, { daily: "DAILY", weekly: "WEEKLY" }

  def eligible_for_disbursement?(date)
    return true if daily?

    live_on.wday == date.wday
  end
end
