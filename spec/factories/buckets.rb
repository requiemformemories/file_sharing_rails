# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :bucket do
    name { Faker::Name.name }
  end
end
