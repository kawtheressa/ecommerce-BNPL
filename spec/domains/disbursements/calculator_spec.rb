require 'rails_helper'

RSpec.describe Disbursements::Calculator, type: :model do
  describe '#calculate_fee' do
    it 'calculates the fee for orders below 50 € with 1.00%' do
      calculator = Disbursements::Calculator.new(49.99)
      expect(calculator.calculate_fee).to eq((49.99 * 0.01).round(2))
    end

    it 'calculates the fee for orders between 50 € and 300 € with 0.95%' do
      calculator = Disbursements::Calculator.new(150.00)
      expect(calculator.calculate_fee).to eq((150.00 * 0.0095).round(2))
    end

    it 'calculates the fee for orders above 300 € with 0.85%' do
      calculator = Disbursements::Calculator.new(500.00)
      expect(calculator.calculate_fee).to eq((500.00 * 0.0085).round(2))
    end
  end
end
