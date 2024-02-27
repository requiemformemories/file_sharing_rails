# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessKey, type: :model do
  it { should belong_to(:user) }

  describe '#generate_access_key callback' do
    subject { access_key.save }
    let(:access_key) { AccessKey.new(user_id: user.id) }
    let(:user) { User.create(username: 'user', password: 'password') }

    it 'generates access key before create' do
      subject
      expect(access_key.secret).not_to be_nil
    end
  end

  describe '#set_expires' do
    subject { access_key.set_expires(value) }
    let(:access_key) { AccessKey.new }
    let(:value) { 3600 }

    it 'sets the expired_at attribute based on the expires value' do
      subject
      expect(access_key.expired_at).to be_within(1.second).of(Time.current + 3600)
    end

    context 'when expires is not a positive integer' do
      let(:value) { -1 }

      it 'raises an error' do
        expect { subject }.to raise_error(AccessKey::InvalidExpires)
      end
    end
  end

  describe '.belongs_to_user' do
    subject { AccessKey.belongs_to_user(user.id) }

    let(:user) { User.create(username: 'user', password: 'password') }
    let(:another_user) { User.create(username: 'user2', password: 'password') }
    let!(:access_key_belongs_to_user) { create(:access_key, user_id: user.id) }
    let!(:access_key_does_not_belongs_to_user) { create(:access_key, user_id: another_user.id) }

    it 'returns access keys that belong to the user' do
      expect(subject.size).to eq(1)
      expect(subject[0]).to eq(access_key_belongs_to_user)
    end
  end

  describe '.active' do
    subject { AccessKey.active }

    let(:user) { User.create(username: 'user', password: 'password') }
    let!(:long_lived_access_key) { create(:access_key, user_id: user.id) }
    let!(:not_expired_access_key) { create(:access_key, user_id: user.id, expired_at: 2.days.after) }
    let!(:expired_access_key) { create(:access_key, user_id: user.id, expired_at: 2.days.ago) }
    let!(:revoked_access_key) { create(:access_key, user_id: user.id, revoked_at: 2.days.ago) }

    it 'returns access keys that belong to the user' do
      expect(subject.size).to eq(2)
      expect(subject).to include(long_lived_access_key, not_expired_access_key)
    end
  end

  describe '.previous_id' do
    subject { AccessKey.previous_id(previous_id) }

    let(:user) { User.create(username: 'user', password: 'password') }
    let!(:access_key1) { create(:access_key, user_id: user.id) }
    let!(:access_key2) { create(:access_key, user_id: user.id) }

    context 'when previous_id is not present' do
      let(:previous_id) { nil }

      it 'returns all access keys' do
        expect(subject.size).to eq(2)
        expect(subject).to include(access_key1, access_key2)
      end
    end
    
    context 'when previous_id is present and the specified record can be retrieved' do
      let(:previous_id) { access_key2.access_id }

      it 'returns access keys that are created before the previous_id' do
        expect(subject.size).to eq(1)
        expect(subject).to include(access_key1)
      end
    end

    context 'when previous_id is present and the specified record can not be retrieved' do
      let(:previous_id) { 'previous_id_not_exist' }

      it 'returns all access keys' do
        expect(subject.size).to eq(2)
        expect(subject).to include(access_key1, access_key2)
      end
    end
  end
end
