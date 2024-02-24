# frozen_string_literal: true

module Api
  class BucketsController < BaseController
    def index
      previous_id = params[:previous_id]
      limit = params[:limit] || 25
      @buckets = Bucket.all
      @buckets = @buckets.where('id < ?', previous_id) if previous_id.present?
      @buckets = @buckets.order(created_at: :desc).limit(limit)

      render json: BucketPresenter.present_collection(@buckets)
    end

    def create
      @bucket = Bucket.new(bucket_params)

      if @bucket.save
        render json: BucketPresenter.new(@bucket).present, status: :created
      else
        render json: { errors: @bucket.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @bucket = Bucket.find_by(id: params[:id])

      if @bucket.nil?
        render json: "Bucket with id##{params[:id]} is not found.", status: :not_found
        return
      end

      @bucket.destroy!

      head :no_content
    end

    private

    def bucket_params
      params.permit(:name)
    end
  end
end
