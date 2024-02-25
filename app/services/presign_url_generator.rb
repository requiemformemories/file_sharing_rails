# frozen_string_literal: true

class PresignUrlGenerator
  include Rails.application.routes.url_helpers

  def initialize(**params)
    @host = params[:host]
    @access_key = params[:access_key]
    @bucket_name = params[:bucket_name]
    @key = params[:key]
    @action = params[:action]
    @expired_at = params[:expired_at]
    @signature_generator = params[:signature_generator] || SignatureGenerator
  end

  def generate
    params = {
      host: @host,
      bucket_name: @bucket_name,
      access_id: @access_key.id,
      key: @key,
      expired_at: @expired_at,
      signature: compute_signature
    }

    case @action
    when 'download'
      api_bucket_objects_download_url(params)
    when 'update', 'destroy'
      api_bucket_objects_url(params)
    else
      raise ArgumentError, 'Invalid action'
    end
  end

  def compute_signature
    @signature_generator.new(
      access_key: @access_key,
      bucket_name: @bucket_name,
      key: @key,
      action: @action,
      expired_at: @expired_at
    ).generate
  end
end
