# frozen_string_literal: true

FactoryBot.define do
  factory :file_object do
    key { Faker::File.file_name(ext: 'jpg') }
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'image.jpg')) }
    bucket
  end
end
