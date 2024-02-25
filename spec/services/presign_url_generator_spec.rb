# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PresignUrlGenerator do
  subject { described_class.new(**params).generate }
  let(:params) do
    {
      host: 'http://localhost:3000',
      access_key: access_key,
      bucket_name: 'bucket_name',
      key: 'file_key',
      action: 'download',
      expired_at: '2024-01-01T00:00:00Z'
    }
  end
  let(:access_key) { double('AccessKey', id: 'access', secret: 'secret') }

  describe '#generate' do
    context 'when action is `download`' do
      it 'returns the download URL' do
        is_expected.to include('http://localhost:3000/api/buckets/bucket_name/objects/download')
        is_expected.to include('access_id=access')
        is_expected.to include('expired_at=2024-01-01T00%3A00%3A00Z')
        is_expected.to include('key=file_key')
        is_expected.to include('signature=c9a606b42a049c7530047725a75aff7d9c81fb783d1a3293ca164eebcf210e15')
      end
    end

    context 'when action is `update`' do
      it 'returns the update URL' do
        is_expected.to include('http://localhost:3000/api/buckets/bucket_name/objects')
        is_expected.to include('access_id=access')
        is_expected.to include('expired_at=2024-01-01T00%3A00%3A00Z')
        is_expected.to include('key=file_key')
        is_expected.to include('signature=c9a606b42a049c7530047725a75aff7d9c81fb783d1a3293ca164eebcf210e15')
      end
    end

    context 'when action is `destroy`' do
      it 'returns the update URL' do
        is_expected.to include('http://localhost:3000/api/buckets/bucket_name/objects')
        is_expected.to include('access_id=access')
        is_expected.to include('expired_at=2024-01-01T00%3A00%3A00Z')
        is_expected.to include('key=file_key')
        is_expected.to include('signature=c9a606b42a049c7530047725a75aff7d9c81fb783d1a3293ca164eebcf210e15')
      end
    end
  end
end
