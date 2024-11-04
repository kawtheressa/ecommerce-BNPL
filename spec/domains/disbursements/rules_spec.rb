require 'rails_helper'

RSpec.describe Disbursements::Rules, type: :module do
  describe '.fee_percentage' do
    it 'returns 1.00% for orders below 50 €' do
      expect(Disbursements::Rules.fee_percentage(49.99)).to eq(0.01)
    end

    it 'returns 0.95% for orders between 50 € and 300 €' do
      expect(Disbursements::Rules.fee_percentage(50.00)).to eq(0.0095)
      expect(Disbursements::Rules.fee_percentage(300.00)).to eq(0.0095)
    end

    it 'returns 0.85% for orders above 300 €' do
      expect(Disbursements::Rules.fee_percentage(300.01)).to eq(0.0085)
    end
  end
end
