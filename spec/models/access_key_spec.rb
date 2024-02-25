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
end
