# frozen_string_literal: true

class AccessKey < ApplicationRecord
  class InvalidExpires < StandardError; end

  belongs_to :user
  before_create :generate_access_key

  def set_expires(expires)
    return false if expires.blank?
    raise InvalidExpires, 'Expires must be a positive integer.' unless expires.to_i.positive?

    self.expired_at = Time.current + expires.to_i
  end

  private

  def generate_access_key
    self.id = SecureRandom.uuid
    self.secret = SecureRandom.hex(32)
  end
end
