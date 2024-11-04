# app/services/disbursement_service.rb
class DisbursementService
  def initialize(merchant)
    @merchant = merchant
  end

  def process_disbursement(date)
    # Calculate the total disbursement for the day
    orders_to_disburse = @merchant.orders.where(disbursement_id: nil).where(created_at: date.beginning_of_day..date.end_of_day)
    return if orders_to_disburse.empty?

    disbursement_amount = orders_to_disburse.sum(&:amount)
    commission_fees = orders_to_disburse.map { |order| Disbursements::Calculator.new(order.amount).calculate_fee }.sum.round(2)

    # Save the disbursement with the calculated fees
    disbursement = Disbursement.create!(
      merchant: @merchant,
      unique_reference: generate_reference,
      total_amount: disbursement_amount,
      commission_fee: commission_fees,
      disbursed_at: date
    )

    # Update the disbursement_id for the orders
    update_disbursement_id(orders_to_disburse, disbursement)
  end

  private

  def first_disbursement_of_month?(date)
    date.day == 1
  end

  def update_disbursement_id(orders_to_disburse, disbursement)
    orders_to_disburse.update_all(disbursement_id: disbursement.id)
  end

  def generate_reference
    SecureRandom.hex(10)
  end
end
