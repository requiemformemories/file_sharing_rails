# frozen_string_literal: true

class SignatureGenerator
  def initialize(**params)
    @access_key = params[:access_key]
    @bucket_name = params[:bucket_name]
    @key = params[:key]
    @action = params[:action]
    @expired_at = params[:expired_at]
  end

  def generate
    OpenSSL::HMAC.hexdigest("SHA256", @access_key.secret, signature_data)
  end

  private

  def signature_data
    "#{@access_key.id}#{@bucket_name}#{@key}#{@action}#{@expired_at}"
  end
end