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
        is_expected.to include('signature=94a789ed585060d3b4a64c00692294818ff191968e6666e412e909d97fbf0ae8')
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
        is_expected.to include('signature=94a789ed585060d3b4a64c00692294818ff191968e6666e412e909d97fbf0ae8')
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
        is_expected.to include('signature=94a789ed585060d3b4a64c00692294818ff191968e6666e412e909d97fbf0ae8')
      end
    end
  end
end
