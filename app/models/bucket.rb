# frozen_string_literal: true

class Bucket < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :user_id }
end
