# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignatureExaminer do
  let(:params) do
    {
      access_key: double('AccessKey'),
      bucket_name: 'test_bucket',
      key: 'test_key',
      action: 'download',
      expired_at:,
      signature: 'test_signature'
    }
  end
  let(:expired_at) { (Time.current + 1.hour).iso8601 }

  subject { described_class.new(**params) }

  describe '#valid_signature?' do
    let(:compute_signature_result) { 'test_signature' }

    before { allow(subject).to receive(:compute_signature).and_return(compute_signature_result) }

    it 'returns true' do
      expect(subject.valid_signature?).to be true
    end

    context 'when the computed signature does not match the provided signature' do
      let(:compute_signature_result) { 'wrong_signature' }

      it 'returns false' do
        allow(subject).to receive(:compute_signature).and_return('wrong_signature')
        expect(subject.valid_signature?).to be false
      end
    end

    context 'when the expired_at time is in the past' do
      let(:expired_at) { (Time.current - 1.hour).iso8601 }

      it 'returns false' do
        expect(subject.valid_signature?).to be false
      end
    end
  end
end
