# spec/services/monthly_fee_calculator_spec.rb
require 'rails_helper'

RSpec.describe MonthlyFeeCalculator, type: :service do
  let(:date) { Date.new(2024, 11, 1) }
  let!(:merchant) { create(:merchant, minimum_monthly_fee: 50.0) }
  let!(:other_merchant) { create(:merchant, minimum_monthly_fee: 100.0) }

  before do
    create(:order, merchant: merchant, amount: 30.0, created_at: date.prev_month.beginning_of_month + 1.day)
    create(:order, merchant: other_merchant, amount: 80.0, created_at: date.prev_month.beginning_of_month + 1.day)
  end

  describe "#process_monthly_fees" do
    context "when calculating fees for a specific merchant" do
      it "records a monthly fee if total commission is below the minimum monthly fee" do
        MonthlyFeeCalculator.new(date: date, merchant: merchant).process_monthly_fees
        monthly_fee = MonthlyFee.find_by(merchant: merchant, fee_month: date.prev_month.beginning_of_month)

        expect(monthly_fee).not_to be_nil
        expect(monthly_fee.amount).to eq(50.0 - (30.0 * 0.01).round(2))

        monthly_fee.destroy!
      end

      it "does not record a monthly fee if the commission meets the minimum fee" do
        merchant.orders.first.update!(amount: 6000.0)

        MonthlyFeeCalculator.new(date: date, merchant: merchant).process_monthly_fees
        monthly_fee = MonthlyFee.find_by(merchant: merchant, fee_month: date.prev_month.beginning_of_month)

        expect(monthly_fee).to be_nil
      end

      it "does not duplicate monthly fee if it is already recorded" do
        MonthlyFee.create!(merchant: merchant, fee_month: date.prev_month.beginning_of_month, amount: 10.0)

        expect { MonthlyFeeCalculator.new(date: date, merchant: merchant).process_monthly_fees }
          .not_to change { MonthlyFee.count }
      end
    end

    context "when calculating fees for all merchants" do
      it "calculates and records monthly fees for all merchants" do
        MonthlyFeeCalculator.new(date: date).process_monthly_fees

        merchant_fee = MonthlyFee.find_by(merchant: merchant, fee_month: date.prev_month.beginning_of_month)
        other_merchant_fee = MonthlyFee.find_by(merchant: other_merchant, fee_month: date.prev_month.beginning_of_month)

        expect(merchant_fee).not_to be_nil
        expect(merchant_fee.amount).to eq(50.0 - (30.0 * 0.01).round(2))

        expect(other_merchant_fee).not_to be_nil
        expect(other_merchant_fee.amount).to eq(100.0 - (80.0 * 0.0095).round(2))
      end
    end
  end
end
