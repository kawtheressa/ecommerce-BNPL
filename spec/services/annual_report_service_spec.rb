# spec/services/annual_report_service_spec.rb
require 'rails_helper'

RSpec.describe AnnualReportService, type: :service do
  let(:service) { AnnualReportService.new }

  before do
    # Create merchants
    @merchant1 = create(:merchant, minimum_monthly_fee: 50.0)
    @merchant2 = create(:merchant, minimum_monthly_fee: 75.0)

    # Create disbursements for 2022
    create(:disbursement, merchant: @merchant1, total_amount: 200.0, commission_fee: 5.0, disbursed_at: Date.new(2022, 1, 1))
    create(:disbursement, merchant: @merchant1, total_amount: 300.0, commission_fee: 7.5, disbursed_at: Date.new(2022, 6, 15))
    create(:disbursement, merchant: @merchant2, total_amount: 150.0, commission_fee: 3.0, disbursed_at: Date.new(2022, 7, 20))

    # Create disbursements for 2023
    create(:disbursement, merchant: @merchant1, total_amount: 400.0, commission_fee: 10.0, disbursed_at: Date.new(2023, 2, 1))
    create(:disbursement, merchant: @merchant2, total_amount: 500.0, commission_fee: 12.5, disbursed_at: Date.new(2023, 3, 15))
    create(:disbursement, merchant: @merchant2, total_amount: 600.0, commission_fee: 15.0, disbursed_at: Date.new(2023, 8, 10))

    # Create monthly fees for 2022
    create(:monthly_fee, merchant: @merchant1, fee_month: Date.new(2022, 1, 1), amount: 50.0)
    create(:monthly_fee, merchant: @merchant2, fee_month: Date.new(2022, 7, 1), amount: 75.0)

    # Create monthly fees for 2023
    create(:monthly_fee, merchant: @merchant1, fee_month: Date.new(2023, 2, 1), amount: 50.0)
    create(:monthly_fee, merchant: @merchant2, fee_month: Date.new(2023, 3, 1), amount: 75.0)
  end

  describe "#generate_report" do
    it "returns the correct report data for each year" do
      report = service.generate_report

      # Find the report data for 2022
      report_2022 = report.find { |data| data[:year] == 2022 }
      expect(report_2022).to eq(
        {
          year: 2022,
          number_of_disbursements: 3,
          amount_disbursed_to_merchants: "650.00 €", # 200 + 300 + 150
          amount_of_order_fees: "15.50 €",            # 5 + 7.5 + 3
          number_of_monthly_fees_charged: 2,
          amount_of_monthly_fee_charged: "125.00 €"   # 50 + 75
        }
      )

      # Find the report data for 2023
      report_2023 = report.find { |data| data[:year] == 2023 }
      expect(report_2023).to eq(
        {
          year: 2023,
          number_of_disbursements: 3,
          amount_disbursed_to_merchants: "1,500.00 €", # 400 + 500 + 600
          amount_of_order_fees: "37.50 €",             # 10 + 12.5 + 15
          number_of_monthly_fees_charged: 2,
          amount_of_monthly_fee_charged: "125.00 €"    # 50 + 75
        }
      )
    end
  end
end
