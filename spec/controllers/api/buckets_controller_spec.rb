# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::BucketsController, type: :controller do
  let(:user) { User.create(username: 'user', password: 'password') }
  let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(user.username, user.password) }
  let(:is_authenticated) { true }

  before do
    request.env['HTTP_AUTHORIZATION'] = credentials if is_authenticated
  end

  describe 'GET #index' do
    subject { get :index, params:, format: :json }

    let(:params) { {} }
    let!(:bucket1) { create(:bucket, name: 'bucket_1', user_id: user.id) }
    let!(:bucket2) { create(:bucket, name: 'bucket_2', user_id: user.id) }

    it 'returns the records successfully' do
      subject

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')

      response_body = JSON.parse(response.body)
      expect(response_body[0]['name']).to eq('bucket_2')
      expect(response_body[1]['name']).to eq('bucket_1')
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
      let(:params) { { limit: 1 } }

      it 'returns the records successfully' do
        subject

        expect(response).to be_successful

        response_body = JSON.parse(response.body)
        expect(response_body.length).to eq(1)
        expect(response_body[0]['name']).to eq('bucket_2')
      end
    end

    context 'with previous_name' do
      let(:params) { { previous_name: bucket2.name } }

      it 'returns the records successfully' do
        subject

        expect(response).to be_successful

        response_body = JSON.parse(response.body)
        expect(response_body[0]['name']).to eq('bucket_1')
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params:, format: :json }

    let(:params) { { name: 'new_bucket' } }

    it 'creates a new bucket' do
      expect { subject }.to change(Bucket, :count).by(1)

      expect(Bucket.last).to have_attributes(name: 'new_bucket')
      expect(Bucket.last).to have_attributes(user_id: user.id)
    end

    it 'returns the record successfully' do
      subject
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')

      response_body = JSON.parse(response.body)
      expect(response_body['name']).to eq('new_bucket')
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

    context 'with invalid parameters' do
      let(:params) { { name: nil } }

      it 'does not create a new bucket' do
        expect { subject }.to change(Bucket, :count).by(0)
      end

      it 'returns the error messages' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        response_body = JSON.parse(response.body)
        expect(response_body['errors'].first).to eq("Name can't be blank")
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params:, format: :json }

    let(:params) { { name: bucket_to_be_deleted.name } }
    let!(:bucket_to_be_deleted) { create(:bucket, name: 'bucket_to_be_deleted', user_id: user.id) }

    it 'destroys the requested bucket' do
      expect { subject }.to change(Bucket, :count).by(-1)
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
end
