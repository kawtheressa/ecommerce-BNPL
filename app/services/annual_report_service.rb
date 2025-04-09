# app/services/annual_report_service.rb
class AnnualReportService
  DEFAULT_YEARS = [2022, 2023]

  def initialize(years = DEFAULT_YEARS)
    @years = years
    @disbursement_cache = {}
    @monthly_fee_cache = {}
  end

  def generate_report
    @years.map do |year|
      {
        year: year,
        number_of_disbursements: disbursements_for_year(year).count,
        amount_disbursed_to_merchants: formatted_currency(disbursements_for_year(year).sum(:total_amount)),
        amount_of_order_fees: formatted_currency(disbursements_for_year(year).sum(:commission_fee)),
        number_of_monthly_fees_charged: monthly_fees_for_year(year).count,
        amount_of_monthly_fee_charged: formatted_currency(monthly_fees_for_year(year).sum(:amount))
      }
    end
  end

  private

  def disbursements_for_year(year)
    @disbursement_cache[year] ||= Disbursement.where(disbursed_at: year_range(year))
  end

  def monthly_fees_for_year(year)
    @monthly_fee_cache[year] ||= MonthlyFee.where(fee_month: year_range(year))
  end

  def year_range(year)
    Date.new(year).beginning_of_year..Date.new(year).end_of_year
  end

  def formatted_currency(amount)
    # Formats currency with comma separators and two decimals
    sprintf("%.2f \u20AC", amount).gsub(/(\d)(?=(\d{3})+\.)/, '\1,')
  end
end
