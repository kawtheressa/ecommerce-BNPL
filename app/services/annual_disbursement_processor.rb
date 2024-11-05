# app/services/annual_disbursement_processor.rb
class AnnualDisbursementProcessor
  def initialize(year)
    @year = year
    @start_date = Date.new(year, 1, 1)
    @end_date = Date.new(year, 12, 31)
  end

  def process_all
    Merchant.find_each do |merchant|
      # Optimize by fetching only the dates with orders within the year
      dates_with_orders = orders_dates_within_year(merchant)

      dates_with_orders.each do |date|
        DisbursementService.new(merchant).process_disbursement(date)
      end
    end
  end

  private

  # Fetch only dates where orders exist for a given merchant within the year
  def orders_dates_within_year(merchant)
    merchant.orders
            .where(created_at: @start_date..@end_date, disbursement_id: nil)
            .pluck(:created_at)
            .map(&:to_date)
            .uniq
  end
end
