# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :bucket do
    name { Faker::Alphanumeric.alpha(number: 10) }
  end
end
