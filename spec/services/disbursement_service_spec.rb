# spec/services/disbursement_service_spec.rb
require 'rails_helper'

RSpec.describe DisbursementService do
  let(:merchant) { create(:merchant) }
  let(:date) { Date.new(2023, 5, 15) }
  let(:service) { described_class.new(merchant) }

  describe "Edge Cases for #process_disbursement" do
    context "when there are no orders for the specified date" do
      it "does not create a disbursement" do
        expect { service.process_disbursement(date) }.not_to change { Disbursement.count }
      end
    end

    context "when there is a single order at the commission threshold (e.g., €50)" do
      let!(:order) { create(:order, merchant: merchant, amount: 50.0, created_at: date.beginning_of_day) }

      it "calculates the correct commission fee" do
        allow_any_instance_of(Disbursements::Calculator).to receive(:calculate_fee).and_return(0.48e0)
        service.process_disbursement(date)

        disbursement = Disbursement.last
        expect(disbursement.commission_fee).to eq(0.48e0.to_f)
      end
    end

    context "when there are orders for different merchants on the same date" do
      let(:other_merchant) { create(:merchant) }
      let!(:order1) { create(:order, merchant: merchant, amount: 100.0, created_at: date.beginning_of_day) }
      let!(:order2) { create(:order, merchant: other_merchant, amount: 150.0, created_at: date.beginning_of_day) }

      it "only disburses orders for the specified merchant" do
        service.process_disbursement(date)
        disbursement = Disbursement.last

        expect(disbursement.total_amount).to eq(order1.amount)
        expect(order2.reload.disbursement_id).to be_nil
      end
    end

    context "when disbursement is processed on the first day of the month" do
      let(:first_day) { Date.new(2023, 5, 1) }
      let!(:order) { create(:order, merchant: merchant, amount: 100.0, created_at: first_day.beginning_of_day) }

      it "recognizes it as the first disbursement of the month" do
        expect(service.send(:first_disbursement_of_month?, first_day)).to be true
        service.process_disbursement(first_day)
        disbursement = Disbursement.last
        expect(disbursement.disbursed_at).to eq(first_day)
      end
    end

    context "when processing a large number of orders" do
      before do
        100.times { create(:order, merchant: merchant, amount: 5.0, created_at: date.beginning_of_day) }
      end

      it "correctly calculates the total amount and commission fees" do
        allow_any_instance_of(Disbursements::Calculator).to receive(:calculate_fee).and_return(0.05)
        service.process_disbursement(date)

        disbursement = Disbursement.last
        expect(disbursement.total_amount).to eq(500.0)
        expect(disbursement.commission_fee).to eq(5.0)
      end
    end
  end
end
