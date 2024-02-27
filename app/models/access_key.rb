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

  scope :belongs_to_user, -> (user_id) { where(user_id: user_id) }
  scope :active, -> { where(revoked_at: nil).where('expired_at > ? OR expired_at IS NULL', Time.current) }
  scope :previous_id, -> (previous_id) {
    next if previous_id.blank?

    cursor_id = find_by(access_id: previous_id)&.id
    next if cursor_id.blank?

    where('id < ?', cursor_id)
  }

  private

  def generate_access_key
    self.access_id = SecureRandom.uuid
    self.secret = SecureRandom.hex(32)
  end
end
