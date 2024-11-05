# spec/services/annual_disbursement_processor_spec.rb
require 'rails_helper'

RSpec.describe AnnualDisbursementProcessor do
  let(:merchant) { create(:merchant) }
  let(:year) { 2022 }
  let(:start_date) { Date.new(year, 1, 1) }
  let(:end_date) { Date.new(year, 12, 31) }
  let(:processor) { described_class.new(year) }

  before do
    # Stub Merchant.find_each to yield our single merchant
    allow(Merchant).to receive(:find_each).and_yield(merchant)
  end

  it "calls DisbursementService#process_disbursement only on dates with orders" do
    # Create orders on specific dates within the year
    dates_with_orders = [
      Date.new(year, 1, 5),
      Date.new(year, 6, 15),
      Date.new(year, 12, 20)
    ]

    # Create orders for the merchant on these dates
    dates_with_orders.each do |date|
      create(:order, merchant: merchant, created_at: date)
    end

    # Mock DisbursementService to verify it’s called only on dates with orders
    disbursement_service = instance_double("DisbursementService")
    allow(DisbursementService).to receive(:new).with(merchant).and_return(disbursement_service)
    allow(disbursement_service).to receive(:process_disbursement)

    # Run the processor
    processor.process_all

    # Expect DisbursementService#process_disbursement to have been called only on the specified dates
    dates_with_orders.each do |date|
      expect(disbursement_service).to have_received(:process_disbursement).with(date)
    end

    # Ensure no other dates were processed
    expect(disbursement_service).to have_received(:process_disbursement).exactly(dates_with_orders.size).times
  end

  it "does not call DisbursementService#process_disbursement when there are no orders" do
    # Ensure no orders exist for this merchant within the year
    expect(merchant.orders.where(created_at: start_date..end_date)).to be_empty

    # Mock DisbursementService to verify it’s not called
    disbursement_service = instance_double("DisbursementService")
    allow(DisbursementService).to receive(:new).with(merchant).and_return(disbursement_service)
    allow(disbursement_service).to receive(:process_disbursement)

    # Run the processor
    processor.process_all

    # Expect DisbursementService#process_disbursement to never be called
    expect(disbursement_service).not_to have_received(:process_disbursement)
  end
end
