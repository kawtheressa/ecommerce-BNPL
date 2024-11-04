# app/services/annual_report_service.rb
class AnnualReportService
  def generate_report
    years = [ 2022, 2023 ]

    report_data = years.map do |year|
      {
        year: year,
        number_of_disbursements: number_of_disbursements(year),
        amount_disbursed_to_merchants: formatted_currency(amount_disbursed_to_merchants(year)),
        amount_of_order_fees: formatted_currency(amount_of_order_fees(year)),
        number_of_monthly_fees_charged: number_of_monthly_fees_charged(year),
        amount_of_monthly_fee_charged: formatted_currency(amount_of_monthly_fee_charged(year))
      }
    end

    report_data
  end

  private

  def number_of_disbursements(year)
    Disbursement.where("EXTRACT(YEAR FROM disbursed_at) = ?", year).count
  end

  def amount_disbursed_to_merchants(year)
    Disbursement.where("EXTRACT(YEAR FROM disbursed_at) = ?", year).sum(:total_amount)
  end

  def amount_of_order_fees(year)
    Disbursement.where("EXTRACT(YEAR FROM disbursed_at) = ?", year).sum(:commission_fee)
  end

  def number_of_monthly_fees_charged(year)
    MonthlyFee.where("EXTRACT(YEAR FROM fee_month) = ?", year).count
  end

  def amount_of_monthly_fee_charged(year)
    MonthlyFee.where("EXTRACT(YEAR FROM fee_month) = ?", year).sum(:amount)
  end

  def formatted_currency(amount)
    # Formats currency with comma separators and two decimals
    sprintf("%.2f \u20AC", amount).gsub(/(\d)(?=(\d{3})+\.)/, '\1,')
  end
end
