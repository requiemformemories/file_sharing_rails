# frozen_string_literal: true

class SignatureExaminer
  def initialize(**params)
    @access_key = params[:access_key]
    @bucket_name = params[:bucket_name]
    @key = params[:key]
    @permission = params[:permission]
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
      permission: @permission,
      expired_at: @expired_at
    ).generate
  end
end
