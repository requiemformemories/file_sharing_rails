# frozen_string_literal: true

class BucketPresenter
  def initialize(bucket)
    @bucket = bucket
  end

  def present
    {
      name: @bucket.name,
      created_at: @bucket.created_at.iso8601
    }
  end

  def self.present_collection(buckets)
    buckets.map { |bucket| new(bucket).present }
  end
end
