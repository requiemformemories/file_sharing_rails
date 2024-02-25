# frozen_string_literal: true

class Bucket < ApplicationRecord
  NAME_FORMAT_ERROR_MESSAGE = 'Name should contain only alphanumeric characters, hyphens, and underscores'

  belongs_to :user
  has_many :file_objects, dependent: :destroy
  validates :name, presence: true, uniqueness: true,
                   format: { with: /\A[\w\-]+\z/, message: NAME_FORMAT_ERROR_MESSAGE }
end
