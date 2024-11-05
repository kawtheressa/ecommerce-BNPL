# app/services/disbursement_service.rb
class DisbursementService
  def initialize(merchant)
    @merchant = merchant
  end

  def process_disbursement(date)
    # Calculate the total disbursement for the day
    orders_to_disburse = @merchant.orders.where(disbursement_id: nil).where(created_at: date.beginning_of_day..date.end_of_day)
    return if orders_to_disburse.empty?

    # Trigger monthly fee calculation on the first disbursement of the month
    if first_disbursement_of_month?(date)
      begin
        MonthlyFeeCalculator.new(date: date, merchant: @merchant).process_monthly_fees
      rescue => e
        log_error("Failed to process monthly fees for #{date} and merchant #{@merchant.id}", e)
      end
    end

    disbursement_amount = calculate_total_amount(orders_to_disburse)
    commission_fees = calculate_total_commission_fees(orders_to_disburse)

    # Save the disbursement with the calculated fees
    disbursement = create_disbursement(disbursement_amount, commission_fees, date)
    return unless disbursement

    # Update the disbursement_id for the orders
    update_disbursement_id(orders_to_disburse, disbursement)
  rescue => e
    log_error("Failed to process disbursement for #{date} and merchant #{@merchant.id}", e)
  end

  private

  def calculate_total_amount(orders)
    orders.sum(&:amount)
  end

  def calculate_total_commission_fees(orders)
    orders.map { |order| Disbursements::Calculator.new(order.amount).calculate_fee }.sum.round(2)
  rescue => e
    log_error("Error calculating commission fees for orders of merchant #{@merchant.id}", e)
    0 # Fallback to zero if fee calculation fails
  end

  def create_disbursement(amount, fees, date)
    Disbursement.create!(
      merchant: @merchant,
      unique_reference: generate_reference,
      total_amount: amount,
      commission_fee: fees,
      disbursed_at: date
    )
  rescue ActiveRecord::RecordInvalid => e
    log_error("Failed to create disbursement for #{date} and merchant #{@merchant.id}", e)
    nil
  end

  def update_disbursement_id(orders_to_disburse, disbursement)
    orders_to_disburse.update_all(disbursement_id: disbursement.id)
  rescue => e
    log_error("Failed to update orders with disbursement ID for disbursement #{disbursement.id}", e)
  end

  def first_disbursement_of_month?(date)
    date.day == 1
  end

  def generate_reference
    SecureRandom.hex(10)
  end

  def log_error(message, exception)
    Rails.logger.error "#{message}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
  end
end
