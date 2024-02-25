# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileObject, type: :model do
  it { should belong_to(:bucket) }
  it { should have_one_attached(:file) }
  it { should validate_presence_of(:key) }
  it { should validate_uniqueness_of(:key).scoped_to(:bucket_id) }
end
