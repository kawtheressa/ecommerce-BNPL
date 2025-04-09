# app/services/annual_disbursement_processor.rb
class AnnualDisbursementProcessor
  def initialize(year)
    @year = year
    @start_date = Date.new(year, 1, 1)
    @end_date = Date.new(year, 12, 31)
  end

  def process_all
    grouped_orders.each do |merchant_id, date|
      merchant = Merchant.find(merchant_id)
      DisbursementService.new(merchant).process_disbursement(date)
    end
  end

  private

  # Fetch merchant IDs and unique order dates within the year
  # How Data Will Look Like:
  # [[1, Mon, 02 Jan 2023],
  # [1, Tue, 03 Jan 2023],
  # [2, Mon, 02 Jan 2023],
  # [3, Wed, 04 Jan 2023]]

  def grouped_orders
    Order.where(created_at: @start_date..@end_date, disbursement_id: nil)
         .group("merchant_id, DATE(created_at)")
         .pluck("merchant_id, DATE(created_at)")
  end
end
