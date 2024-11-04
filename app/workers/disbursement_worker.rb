# app/workers/disbursement_worker.rb
class DisbursementWorker
  include Sidekiq::Worker

  def perform
    MerchantRepository.all.each do |merchant|
      next unless merchant.eligible_for_disbursement?(Date.today)

      DisbursementService.new(merchant).process_disbursement(Date.today)
    end
  end
end
