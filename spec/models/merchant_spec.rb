# spec/models/merchant_spec.rb
require 'rails_helper'

RSpec.describe Merchant, type: :model do
  let(:merchant) { build(:merchant) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(merchant).to be_valid
    end

    it "is not valid without a reference" do
      merchant.reference = nil
      expect(merchant).not_to be_valid
      expect(merchant.errors[:reference]).to include("can't be blank")
    end

    it "is not valid without an email" do
      merchant.email = nil
      expect(merchant).not_to be_valid
      expect(merchant.errors[:email]).to include("can't be blank")
    end

    it "is not valid without a live_on date" do
      merchant.live_on = nil
      expect(merchant).not_to be_valid
      expect(merchant.errors[:live_on]).to include("can't be blank")
    end

    it "is not valid without a disbursement_frequency" do
      merchant.disbursement_frequency = nil
      expect(merchant).not_to be_valid
      expect(merchant.errors[:disbursement_frequency]).to include("can't be blank")
    end

    it "is not valid without a minimum_monthly_fee" do
      merchant.minimum_monthly_fee = nil
      expect(merchant).not_to be_valid
      expect(merchant.errors[:minimum_monthly_fee]).to include("can't be blank")
    end
  end

  describe "associations" do
    it { should have_many(:orders) }
    it { should have_many(:disbursements) }
  end

  describe "enums" do
    it "defines disbursement_frequency enum with correct values" do
      expect(Merchant.disbursement_frequencies).to eq({ "daily" => "DAILY", "weekly" => "WEEKLY" })
    end
  end

  describe "#eligible_for_disbursement?" do
    context "when disbursement_frequency is daily" do
      it "returns true for any date" do
        merchant.disbursement_frequency = "daily"
        expect(merchant.eligible_for_disbursement?(Date.today)).to be true
      end
    end

    context "when disbursement_frequency is weekly" do
      before { merchant.disbursement_frequency = "weekly" }

      it "returns true if the given date matches the live_on weekday" do
        merchant.live_on = Date.new(2023, 1, 2) # It's a Monday
        date = Date.new(2023, 1, 9) # Another Monday
        expect(merchant.eligible_for_disbursement?(date)).to be true
      end

      it "returns false if the given date does not match the live_on weekday" do
        merchant.live_on = Date.new(2023, 1, 2) # It's a Monday
        date = Date.new(2023, 1, 10) # Not a Monday
        expect(merchant.eligible_for_disbursement?(date)).to be false
      end
    end
  end
end
