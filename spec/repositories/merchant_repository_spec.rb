# spec/repositories/merchant_repository_spec.rb
require 'rails_helper'

RSpec.describe MerchantRepository do
  let!(:merchant1) { create(:merchant) }
  let!(:merchant2) { create(:merchant) }

  describe ".all" do
    it "returns all merchants" do
      result = MerchantRepository.all
      expect(result).to contain_exactly(merchant1, merchant2)
    end
  end
end
