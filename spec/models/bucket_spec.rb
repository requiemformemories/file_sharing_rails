# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bucket, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should allow_value('valid_name').for(:name) }
    it { should_not allow_value('invalid^U^name///').for(:name).with_message(Bucket::NAME_FORMAT_ERROR_MESSAGE) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:file_objects).dependent(:destroy) }
  end
end
