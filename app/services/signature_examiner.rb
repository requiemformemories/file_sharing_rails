# frozen_string_literal: true

class SignatureExaminer
  def initialize(**params)
    @access_key = params[:access_key]
    @bucket_name = params[:bucket_name]
    @key = params[:key]
    @action = params[:action]
    @permission = params[:permission]
    @expired_at = params[:expired_at]
    @signature = params[:signature]
    @signature_generator = params[:signature_generator] || SignatureGenerator
  end

  def valid_signature?
    return false if expired?
    return false if @permission != permission_from_action

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

  def permission_from_action
    case @action
    when 'download'
      'read'
    when 'update'
      'update'
    when 'destroy'
      'delete'
    end
  end
end
