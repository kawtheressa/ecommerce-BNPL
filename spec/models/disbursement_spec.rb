# spec/models/disbursement_spec.rb
require 'rails_helper'

RSpec.describe Disbursement, type: :model do
  let(:disbursement) { build(:disbursement) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(disbursement).to be_valid
    end

    it "is not valid without a unique_reference" do
      disbursement.unique_reference = nil
      expect(disbursement).not_to be_valid
      expect(disbursement.errors[:unique_reference]).to include("can't be blank")
    end

    it "is not valid with a duplicate unique_reference" do
      create(:disbursement, unique_reference: disbursement.unique_reference)
      expect(disbursement).not_to be_valid
      expect(disbursement.errors[:unique_reference]).to include("has already been taken")
    end

    it "is not valid without a total_amount" do
      disbursement.total_amount = nil
      expect(disbursement).not_to be_valid
      expect(disbursement.errors[:total_amount]).to include("can't be blank")
    end

    it "is not valid without a commission_fee" do
      disbursement.commission_fee = nil
      expect(disbursement).not_to be_valid
      expect(disbursement.errors[:commission_fee]).to include("can't be blank")
    end

    it "is not valid without a disbursed_at date" do
      disbursement.disbursed_at = nil
      expect(disbursement).not_to be_valid
      expect(disbursement.errors[:disbursed_at]).to include("can't be blank")
    end
  end

  describe "associations" do
    it { should have_many(:orders) }
    it { should belong_to(:merchant) }
  end
end
