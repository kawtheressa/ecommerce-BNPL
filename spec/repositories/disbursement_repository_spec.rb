# spec/repositories/disbursement_repository_spec.rb
require 'rails_helper'

RSpec.describe DisbursementRepository do
  let(:merchant) { create(:merchant) }
  let!(:disbursement1) { create(:disbursement, merchant: merchant, commission_fee: 5, disbursed_at: Date.new(2023, 1, 15)) }
  let!(:disbursement2) { create(:disbursement, merchant: merchant, commission_fee: 10, disbursed_at: Date.new(2023, 2, 15)) }

  describe ".find_by_year" do
    it "returns disbursements for the specified year" do
      result = DisbursementRepository.find_by_year(2023)
      expect(result).to contain_exactly(disbursement1, disbursement2)
    end
  end

  describe ".commission_for_merchant_in_period" do
    it "calculates total commission for a merchant in a specific period" do
      start_date = Date.new(2023, 1, 1)
      end_date = Date.new(2023, 1, 31)
      result = DisbursementRepository.commission_for_merchant_in_period(merchant.id, start_date, end_date)
      expect(result).to eq(5)
    end
  end
end
