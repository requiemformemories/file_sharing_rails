# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::FileObjectsController, type: :controller do
  let(:user) { User.create(username: 'user', password: 'password') }
  let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(user.username, user.password) }  
  let(:is_authenticated) { true }
  let(:image_jpg_file) { File.open(Rails.root.join('spec', 'fixtures', 'image.jpg')) }
  let(:image_png_file) { File.open(Rails.root.join('spec', 'fixtures', 'image.png')) }
  let(:json_file) { File.open(Rails.root.join('spec', 'fixtures', 'file.json')) }

  before do
    request.env['HTTP_AUTHORIZATION'] = credentials if is_authenticated
  end

  describe 'GET #index' do
    subject { get :index, params:, format: :json }

    let(:params) { { bucket_id: bucket.id } }
    let!(:bucket) { create(:bucket, user_id: user.id) }
    let!(:file_object1) { create(:file_object, bucket_id: bucket.id, key: 'a/b/image1.jpg', file: image_jpg_file) }
    let!(:file_object2) { create(:file_object, bucket_id: bucket.id, key: 'a/b/image2.png', file: image_png_file) }

    it 'returns the records successfully' do
      subject

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')

      response_body = JSON.parse(response.body)

      expect(response_body[0]['key']).to eq('a/b/image2.png')
      expect(response_body[0]['byte_size']).to eq(118)
      expect(response_body[0]['checksum']).to eq('z5LLDUwAMdpC66y/uvHbSg==')
      expect(response_body[1]['key']).to eq('a/b/image1.jpg')
      expect(response_body[1]['byte_size']).to eq(285)
      expect(response_body[1]['checksum']).to eq('RV9amDArDEa5hv8s8CTxyQ==')
    end

    context 'when the request is not authenticated' do
      let(:is_authenticated) { false }

      it 'returns the error messages' do
        subject
        expect(response).to have_http_status(:unauthorized)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Invalid credentials')
      end
    end

    context 'with limit' do
      let(:params) { { bucket_id: bucket.id, limit: 1 } }

      it 'returns the records successfully' do
        subject

        expect(response).to be_successful

        response_body = JSON.parse(response.body)
        expect(response_body.length).to eq(1)
        expect(response_body[0]['key']).to eq('a/b/image2.png')
      end
    end

    context 'with previous_id' do
      let(:params) { { bucket_id: bucket.id, previous_id: file_object2.id } }

      it 'returns the records successfully' do
        subject

        expect(response).to be_successful

        response_body = JSON.parse(response.body)
        expect(response_body[0]['key']).to eq('a/b/image1.jpg')
      end
    end
  end

  describe 'PUT #update' do
    subject { put :update, params:, body:, format: :json }

    let(:params) { { bucket_id: bucket.id, key: 'c/d/image.jpg' } }
    let(:body) { File.read(Rails.root.join('spec', 'fixtures', 'image.jpg')) }
    let!(:bucket) { create(:bucket, user_id: user.id) }

    it 'update the FileObject' do
      subject

      file_object = FileObject.find_by(bucket_id: bucket.id, key: 'c/d/image.jpg')
      expect(file_object).to have_attributes(key: 'c/d/image.jpg')
    end

    it 'returns the record successfully' do
      subject
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')

      response_body = JSON.parse(response.body)
      expect(response_body['key']).to eq('c/d/image.jpg')
      expect(response_body['byte_size']).to eq(285)
      expect(response_body['checksum']).to eq('RV9amDArDEa5hv8s8CTxyQ==')
    end

    context 'when the request is not authenticated' do
      let(:is_authenticated) { false }

      it 'returns the error messages' do
        subject
        expect(response).to have_http_status(:unauthorized)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Invalid credentials')
      end
    end

    context 'when the key is not provided' do
      let(:params) { { bucket_id: bucket.id, key: '' } }

      it 'returns the error messages' do
        subject
        expect(response).to have_http_status(:bad_request)

        response_body = JSON.parse(response.body)
        expect(response_body['message']).to eq('Key should not be blank.')
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params:, format: :json }

    let(:params) { { bucket_id: bucket.id, key: 'a/b/image_to_delete.jpg' } }
    let!(:bucket) { create(:bucket, user_id: user.id) }
    let!(:file_object_to_delete) do
      create(:file_object, bucket_id: bucket.id, key: 'a/b/image_to_delete.jpg', file: image_jpg_file)
    end

    it 'destroys the requested bucket' do
      expect { subject }.to change(FileObject, :count).by(-1)
    end

    it 'returns the status successfully' do
      subject
      expect(response).to be_successful
      expect(response.body).to be_empty
    end

    context 'when the request is not authenticated' do
      let(:is_authenticated) { false }

      it 'returns the error messages' do
        subject
        expect(response).to have_http_status(:unauthorized)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Invalid credentials')
      end
    end
  end

  describe 'GET #download' do
    subject { get :download, params:, format: :json }

    let(:params) { { bucket_id: bucket.id, key: 'file.json' } }
    let!(:bucket) { create(:bucket, user_id: user.id) }
    let!(:file_object1) { create(:file_object, bucket_id: bucket.id, key: 'file.json', file: json_file) }

    it 'returns the status successfully' do
      subject
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json')
      expect(response.body).to eq('{ "result": "success" }')
    end

    context 'when the request is not authenticated' do
      let(:is_authenticated) { false }

      it 'returns the error messages' do
        subject
        expect(response).to have_http_status(:unauthorized)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Invalid credentials')
      end
    end
  end
end
