# frozen_string_literal: true

class SignatureExaminer
  attr_reader :access_id, :bucket_name, :key, :action, :created_at, :expired_at, :signature

  def initialize(**params)
    @access_key = params[:access_key]
    @bucket_name = params[:bucket_name]
    @key = params[:key]
    @action = params[:action]
    @expired_at = params[:expired_at]
    @signature = params[:signature]
    @signature_generator = params[:signature_generator] || SignatureGenerator
  end

  def valid_signature?
    return false if expired?

    compute_signature == @signature
  end

  private

  def expired?
    Time.parse(@expired_at) < Time.current
  rescue ArgumentError, TypeError
    true
  end

  def compute_signature
    @signature_generator.new(
      access_key: @access_key,
      bucket_name: @bucket_name,
      key: @key,
      action: @action,
      expired_at: @expired_at).generate
  end
end