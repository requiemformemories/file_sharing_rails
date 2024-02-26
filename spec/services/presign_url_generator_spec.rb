# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PresignUrlGenerator do
  subject { described_class.new(**params).generate }
  let(:params) do
    {
      host: 'http://localhost:3000',
      access_key:,
      bucket_name: 'bucket_name',
      key: 'file_key',
      action: action,
      expired_at: '2024-01-01T00:00:00Z'
    }
  end
  let(:access_key) { double('AccessKey', access_id: 'access', secret: 'secret') }

  describe '#generate' do
    let(:action) { 'download' }
    
    context 'when action is `download`' do
      it 'returns the download URL' do
        is_expected.to include('http://localhost:3000/api/buckets/bucket_name/objects/download')
        is_expected.to include('access_id=access')
        is_expected.to include('expired_at=2024-01-01T00%3A00%3A00Z')
        is_expected.to include('key=file_key')
        is_expected.to include('permission=read')
        is_expected.to include('signature=414974b6536b7fc1cda0dc505b1688d97eca02d247ecfc619ff72ce2887c82fa')
      end
    end

    context 'when action is `update`' do
      let(:action) { 'update' }

      it 'returns the update URL' do
        is_expected.to include('http://localhost:3000/api/buckets/bucket_name/objects')
        is_expected.to include('access_id=access')
        is_expected.to include('expired_at=2024-01-01T00%3A00%3A00Z')
        is_expected.to include('key=file_key')
        is_expected.to include('permission=update')
        is_expected.to include('signature=95e92c41cfd456a0676e9dc92c6962cdff5f359833dfc579a5983e2b5f8a455f')
      end
    end

    context 'when action is `destroy`' do
      let(:action) { 'destroy' }

      it 'returns the update URL' do
        is_expected.to include('http://localhost:3000/api/buckets/bucket_name/objects')
        is_expected.to include('access_id=access')
        is_expected.to include('expired_at=2024-01-01T00%3A00%3A00Z')
        is_expected.to include('key=file_key')
        is_expected.to include('permission=delete')
        is_expected.to include('signature=9f6efcba3ba7c63ada0c1e1bb4cdf84be8d30ab08222fc06297b5b199e82546d')
      end
    end
  end
end
