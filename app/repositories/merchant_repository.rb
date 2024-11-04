# app/repositories/merchant_repository.rb
class MerchantRepository
  # Fetches all merchants
  def self.all
    Merchant.all
  end
end
