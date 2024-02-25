# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AccessKeysController, type: [:controller] do
  let(:user) { User.create(username: 'user', password: 'password') }
  let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(user.username, user.password) }
  let(:is_authenticated) { true }

  before do
    request.env['HTTP_AUTHORIZATION'] = credentials if is_authenticated
  end

  describe 'GET #index' do
    subject { get :index, params:, format: :json }

    let(:params) { {} }
    let!(:access_key1) { create(:access_key, user_id: user.id) }
    let!(:access_key2) { create(:access_key, user_id: user.id) }

    it 'returns a list of access keys' do
      subject

      expect(response).to be_successful
      response_body = JSON.parse(response.body)
      expect(response_body[0]['id']).to eq(access_key2.id)
      expect(response_body[1]['id']).to eq(access_key1.id)
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
      end
    end

    context 'with previous_id' do
      let(:params) { { previous_id: access_key2.id } }

      it 'returns the records successfully' do
        subject

        expect(response).to be_successful

        response_body = JSON.parse(response.body)
        expect(response_body[0]['id']).to eq(access_key1.id)
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: }

    let(:params) { { expires: 3600 } }

    it 'creates a new access key' do
      subject

      expect(response).to have_http_status(:created)
      expect(AccessKey.count).to eq(1)
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

    context 'when expires parameter is invalid' do
      let(:params) { { expires: 'invalid_date' } }
      it 'returns an error if expires parameter is invalid' do
        subject

        expect(response).to have_http_status(:bad_request)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to eq('Expires must be a positive integer.')
      end
    end
  end

  describe 'POST #revoke' do
    subject { post :revoke, params: }

    let(:params) { { id: access_key.id } }
    let(:access_key) { create(:access_key, user_id: user.id) }

    it 'returns record successfully' do
      subject

      expect(response).to have_http_status(:ok)

      response_body = JSON.parse(response.body)
      expect(response_body['id']).to eq(access_key.id)
      expect(response_body['revoked_at']).not_to be_nil
    end

    it 'revokes the access key' do
      subject

      expect(access_key.reload.revoked_at).not_to be_nil
    end

    context 'when the access key is not found' do
      let(:params) { { id: 'access_key_not_exist' } }

      it 'returns an error' do
        subject

        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq('AccessKey with id#access_key_not_exist is not found.')
      end
    end

    context 'when the access key is already revoked' do
      let(:access_key) { create(:access_key, user_id: user.id, revoked_at: Time.current) }

      it 'returns an error' do
        subject

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include("AccessKey with id##{access_key.id} is already revoked.")
      end
    end
  end
end
