# frozen_string_literal: true

module Api
  class BucketsController < BaseController
    def index
      previous_name = params[:previous_name]
      limit = params[:limit] || 25

      @buckets = Bucket.where(user_id: @current_user.id).all
      @buckets = @buckets.where('name < ?', previous_name) if previous_name.present?
      @buckets = @buckets.order(created_at: :desc).limit(limit)

      render json: BucketPresenter.present_collection(@buckets)
    end

    def create
      @bucket = Bucket.new(bucket_params)
      @bucket.user_id = @current_user.id

      if @bucket.save
        render json: BucketPresenter.new(@bucket).present, status: :created
      else
        render json: { errors: @bucket.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @bucket = Bucket.find_by(name: params[:name], user_id: @current_user.id)

      if @bucket.nil?
        render json: "Bucket with name #{params[:name]} is not found.", status: :not_found
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
