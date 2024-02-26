# frozen_string_literal: true

class FileObject < ApplicationRecord
  belongs_to :bucket
  has_one_attached :file

  validates :key, presence: true, uniqueness: { scope: :bucket_id }, format: { with: %r{\A[A-Za-z0-9_\-/.]+\z} }
end
