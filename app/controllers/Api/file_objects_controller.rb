# frozen_string_literal: true

module Api
  class FileObjectsController < BaseController
    before_action :set_bucket
    before_action :set_key, only: %i[update destroy download]

    def index
      previous_key = params[:previous_key]
      limit = params[:limit] || 25

      file_objects = FileObject.includes(file_attachment: :blob).where(bucket_id: @bucket.id)
      cursor_id_query = file_objects.select(:id).where(key: previous_key, bucket_id: @bucket.id) if previous_key.present?
      file_objects = file_objects.where('id < (?)', cursor_id_query) if cursor_id_query.present?
      file_objects = file_objects.order(id: :desc).limit(limit)

      render json: FileObjectPresenter.present_collection(file_objects)
    end

    def update
      file_object = FileObject.find_or_initialize_by(key: @key, bucket_id: @bucket.id)
      if request.body.size.zero?
        render json: { message: 'File is empty.' }, status: :bad_request
        return
      end

      file_object.file.attach(io: request.body, filename: @key.split('/').last)

      if file_object.save
        render json: FileObjectPresenter.new(file_object).present, status: :created
      else
        render json: { errors: file_object.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      file_object = FileObject.find_by(key: @key, bucket_id: @bucket.id)

      if file_object.nil?
        render json: { message: "File object with key #{@key} is not found." }, status: :not_found
        return
      end

      file_object.destroy!

      head :no_content
    end

    def download
      file_object = FileObject.find_by(key: @key, bucket_id: @bucket.id)

      if file_object.nil?
        render json: { message: "File object with key #{@key} is not found." }, status: :not_found
        return
      end

      send_data(file_object.file.download, type: file_object.file.content_type)
    end

    private

    def set_bucket
      @bucket = Bucket.find_by(name: params[:bucket_name], user_id: @current_user.id)

      return unless @bucket.nil?

      render json: { message: "Bucket with name #{params[:bucket_name]} is not found." }, status: :not_found
    end

    def set_key
      @key = params[:key]
      render json: { message: 'Key should not be blank.' }, status: :bad_request if @key.blank?

      @key.gsub(%r{^/}, '') if @key.present?
    end

    def file_object_params
      params.require(:file_object).permit(:file)
    end
  end
end
