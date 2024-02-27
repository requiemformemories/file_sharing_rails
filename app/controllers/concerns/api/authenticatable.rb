module Api::Authenticatable
  extend ActiveSupport::Concern

  included do
    rescue_from InvalidCredentials, with: :handle_invalid_credentials
  end

  class InvalidCredentials < StandardError; end

  private

  def authenticate_signature!
    return if params[:signature].blank?

    access_key = AccessKey.active.find_by(access_id: params[:access_id])
    raise InvalidCredentials if access_key.nil?

    is_valid = SignatureExaminer.new(
      access_key:,
      bucket_name: params[:bucket_name],
      key: params[:key],
      action: action_name,
      permission: params[:permission],
      expired_at: params[:expired_at],
      signature: params[:signature]
    ).valid_signature?

    raise InvalidCredentials unless is_valid

    @current_user = access_key.user
  end

  def authenticate_http_basic_auth!
    return if @current_user.present?

    @current_user = authenticate_with_http_basic do |username, password|
      User.find_by(username:)&.authenticate(password)
    end

    raise InvalidCredentials if @current_user.nil?
  end

  def handle_invalid_credentials
    render json: { error: 'Invalid credentials' }, status: :unauthorized
  end
end