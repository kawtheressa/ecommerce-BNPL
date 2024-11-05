# app/services/monthly_fee_calculator.rb
class MonthlyFeeCalculator
  def initialize(date: Date.today, merchant: nil)
    @date = date
    @merchant = merchant
  end

  def process_monthly_fees
    merchants = fetch_merchants
    merchants.each { |merchant| handle_merchant_fees(merchant) }
  end

  private

  def fetch_merchants
    @merchant ? [ @merchant ] : Merchant.find_each
  end

  def handle_merchant_fees(merchant)
    previous_month = @date.prev_month
    first_disbursement_date = previous_month.beginning_of_month

    # Skip if already calculated for the first disbursement of the month
    return if monthly_fee_recorded?(merchant, first_disbursement_date)

    # Get total commission for previous month
    total_commission = calculate_total_commission(merchant, previous_month)
    minimum_fee = merchant.minimum_monthly_fee

    # Determine if there’s a shortfall
    if total_commission < minimum_fee
      shortfall = minimum_fee - total_commission
      record_monthly_fee(merchant, shortfall, first_disbursement_date)
    end
  end

  def monthly_fee_recorded?(merchant, date)
    # Check if monthly fee already recorded for the given month
    MonthlyFee.exists?(merchant: merchant, fee_month: date.beginning_of_month)
  end

  def calculate_total_commission(merchant, month)
    orders = Order.where(merchant: merchant)
                  .where("created_at >= ? AND created_at < ?", month.beginning_of_month, month.end_of_month)

    orders.map { |order| Disbursements::Calculator.new(order.amount).calculate_fee }.sum.round(2)
  end

  def record_monthly_fee(merchant, shortfall, date)
    MonthlyFee.create!(
      merchant: merchant,
      fee_month: date.beginning_of_month,
      amount: shortfall
    )
  end
end
