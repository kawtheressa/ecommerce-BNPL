# spec/models/order_spec.rb
require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { build(:order) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(order).to be_valid
    end

    it "is not valid without an amount" do
      order.amount = nil
      expect(order).not_to be_valid
      expect(order.errors[:amount]).to include("can't be blank")
    end
  end

  describe "associations" do
    it { should belong_to(:merchant) }
    it { should belong_to(:disbursement).optional }
  end
end
