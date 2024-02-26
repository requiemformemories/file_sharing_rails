# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignatureGenerator do
  describe '#generate' do
    let(:access_key) { double('AccessKey', id: 'access_key', secret: 'secret') }

    it 'returns a signature' do
      generator = SignatureGenerator.new(access_key:, bucket_name: 'bucket', key: 'key', permission: 'create',
                                         expired_at: '2024-01-01T01:01:01Z')
      signature = generator.generate
      expect(signature).to eq('4fd04867f143d3592ecabf70f89c9f0cebec32b4cd4ade28fe0d5f0e4f5e6897')
    end
  end
end
