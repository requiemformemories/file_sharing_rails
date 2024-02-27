# frozen_string_literal: true

module Api
  class AccessKeysController < BaseController
    def index
      previous_id = params[:previous_id]
      limit = params[:limit] || 25

      access_keys = AccessKey.belongs_to_user(@current_user.id).previous_id(previous_id).order(id: :desc).limit(limit)

      render json: AccessKeyPresenter.present_collection(access_keys, provide_secret: false)
    end

    def create
      access_key = AccessKey.belongs_to_user(@current_user.id).new
      access_key.set_expires(params[:expires])

      if access_key.save
        render json: AccessKeyPresenter.new(access_key).present(provide_secret: true), status: :created
      else
        render json: { errors: access_key.errors.full_messages }, status: :unprocessable_entity
      end
    rescue AccessKey::InvalidExpires => e
      render json: { error: e.message }, status: :bad_request
    end

    def revoke
      access_key = AccessKey.belongs_to_user(@current_user.id).find_by(access_id: params[:id])

      if access_key.nil?
        render json: "AccessKey with id##{params[:id]} is not found.", status: :not_found
        return
      end

      if access_key.revoked_at.present?
        render json: "AccessKey with id##{params[:id]} is already revoked.", status: :bad_request
        return
      end

      access_key.update(revoked_at: Time.current)

      render json: AccessKeyPresenter.new(access_key).present(provide_secret: false)
    end
  end
end
