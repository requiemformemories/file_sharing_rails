# frozen_string_literal: true

class AccessKeyPresenter
  def initialize(access_key)
    @access_key = access_key
  end

  def present(provide_secret:)
    {
      id: @access_key.id,
      created_at: @access_key.created_at.iso8601,
      expired_at: @access_key.expired_at&.iso8601,
      revoked_at: @access_key.revoked_at&.iso8601
    }.tap do |hash|
      hash[:secret] = @access_key.secret if provide_secret
    end
  end

  def self.present_collection(access_keys, provide_secret:)
    access_keys.map { |access_key| new(access_key).present(provide_secret:) }
  end
end
