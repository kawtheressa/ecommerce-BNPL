# spec/workers/disbursement_worker_spec.rb
require 'rails_helper'

RSpec.describe DisbursementWorker, type: :worker do
  let(:daily_merchant) { create(:merchant, disbursement_frequency: 'DAILY', live_on: Date.today) }
  let(:weekly_merchant) { create(:merchant, disbursement_frequency: 'WEEKLY', live_on: Date.today) }
  let(:ineligible_merchant) { create(:merchant, disbursement_frequency: 'WEEKLY', live_on: Date.today - 1.day) }

  before do
    allow_any_instance_of(DisbursementService).to receive(:process_disbursement)
  end

  describe 'job enqueuing' do
    it 'enqueues a disbursement worker job' do
      expect { DisbursementWorker.perform_async }.to change(DisbursementWorker.jobs, :size).by(1)
    end
  end

  describe '#perform' do
    context 'when there are eligible merchants' do
      it 'processes daily merchants' do
        daily_merchant
        expect_any_instance_of(DisbursementService).to receive(:process_disbursement).with(Date.today)
        DisbursementWorker.new.perform
      end

      it 'processes weekly merchants if today is their scheduled day' do
        weekly_merchant
        expect_any_instance_of(DisbursementService).to receive(:process_disbursement).with(Date.today)
        DisbursementWorker.new.perform
      end
    end

    context 'when there are ineligible merchants' do
      it 'does not process merchants not scheduled for disbursement today' do
        ineligible_merchant
        expect_any_instance_of(DisbursementService).not_to receive(:process_disbursement)
        DisbursementWorker.new.perform
      end
    end
  end
end
