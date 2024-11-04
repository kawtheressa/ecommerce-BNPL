# app/repositories/disbursement_repository.rb
class DisbursementRepository
  # Finds all disbursements for a given year
  def self.find_by_year(year)
    Disbursement.where("extract(year from disbursed_at) = ?", year)
  end

  # Sum of commission fees for a merchant in a specific period
  def self.commission_for_merchant_in_period(merchant_id, start_date, end_date)
    Disbursement.where(merchant_id: merchant_id, disbursed_at: start_date..end_date).sum(:commission_fee)
  end
end
