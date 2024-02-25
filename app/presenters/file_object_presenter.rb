# frozen_string_literal: true

class FileObjectPresenter
  def initialize(file_object)
    @file_object = file_object
  end

  def present
    {
      key: @file_object.key,
      content_type: @file_object.file.content_type,
      byte_size: @file_object.file.byte_size,
      checksum: @file_object.file.checksum,
      uploaded_at: @file_object.updated_at.iso8601
    }
  end

  def self.present_collection(file_objects)
    file_objects.map { |file_object| new(file_object).present }
  end
end
