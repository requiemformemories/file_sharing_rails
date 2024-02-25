# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignatureGenerator do
  describe '#generate' do
    let(:access_key) { double('AccessKey', id: 'access_key', secret: 'secret') }

    it 'returns a signature' do
      generator = SignatureGenerator.new(access_key:, bucket_name: 'bucket', key: 'key', action: 'download',
                                         expired_at: '2024-01-01T01:01:01Z')
      signature = generator.generate
      expect(signature).to eq('51fac7eb36871ecb25c1b03a03ef2ce321f4210415c6ded90153e0c6159f6a93')
    end
  end
end
