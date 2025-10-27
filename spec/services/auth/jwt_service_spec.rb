require 'rails_helper'

RSpec.describe Auth::JwtService do
  let(:user) { create(:user) }
  let(:payload) { { user_id: user.id } }

  describe '.encode' do
    it 'generates a JWT token' do
      token = described_class.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT has 3 parts
    end

    it 'includes expiration time' do
      token = described_class.encode(payload)
      decoded = JWT.decode(token, described_class::SECRET_KEY)[0]
      expect(decoded['exp']).to be_present
    end

    it 'allows custom expiration time' do
      custom_exp = 7.days.from_now
      token = described_class.encode(payload, custom_exp)
      decoded = JWT.decode(token, described_class::SECRET_KEY)[0]
      expect(Time.at(decoded['exp'])).to be_within(1.second).of(custom_exp)
    end
  end

  describe '.decode' do
    it 'decodes a valid token' do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)

      expect(decoded['user_id']).to eq(user.id)
      expect(decoded['exp']).to be_present
    end

    it 'returns nil for invalid token' do
      expect(described_class.decode('invalid_token')).to be_nil
    end

    it 'returns nil for expired token' do
      token = described_class.encode(payload, 1.hour.ago)
      expect(described_class.decode(token)).to be_nil
    end
  end

  describe '.encode_for_user' do
    it 'includes user_id and password_version in payload' do
      token = described_class.encode_for_user(user)
      decoded = JWT.decode(token, described_class::SECRET_KEY)[0]

      expect(decoded['user_id']).to eq(user.id)
      expect(decoded['password_version']).to eq(user.password_version)
    end

    it 'updates password_version when user password changes' do
      initial_token = described_class.encode_for_user(user)
      initial_decoded = JWT.decode(initial_token, described_class::SECRET_KEY)[0]
      initial_version = initial_decoded['password_version']

      user.update(password: 'newpassword123')

      new_token = described_class.encode_for_user(user.reload)
      new_decoded = JWT.decode(new_token, described_class::SECRET_KEY)[0]

      expect(new_decoded['password_version']).to eq(initial_version + 1)
    end
  end

  describe '.generate_refresh_token' do
    it 'creates a RefreshToken record for the user' do
      expect {
        result = described_class.generate_refresh_token(user)
        expect(result[:refresh_token]).to be_a(RefreshToken)
      }.to change { user.refresh_tokens.count }.by(1)
    end

    it 'sets expiration to 30 days from now' do
      result = described_class.generate_refresh_token(user)
      token = result[:refresh_token]

      expect(token.expires_at).to be_within(1.minute).of(30.days.from_now)
    end

    it 'returns the plain token and refresh_token object' do
      result = described_class.generate_refresh_token(user)

      expect(result[:token]).to be_a(String)
      expect(result[:refresh_token]).to be_a(RefreshToken)
    end
  end

  describe '.verify_refresh_token' do
    let!(:refresh_token) { create(:refresh_token, user: user, expires_at: 30.days.from_now) }

    before do
      refresh_token.generate_token
      refresh_token.save!
    end

    it 'returns the refresh_token if valid' do
      result = described_class.verify_refresh_token(refresh_token.token)
      expect(result).to eq(refresh_token)
    end

    it 'returns nil for invalid token string' do
      result = described_class.verify_refresh_token('invalid_token')
      expect(result).to be_nil
    end

    it 'returns nil for expired token' do
      refresh_token.update(expires_at: 1.day.ago)
      result = described_class.verify_refresh_token(refresh_token.token)
      expect(result).to be_nil
    end

    it 'returns nil for revoked token' do
      refresh_token.revoke!
      result = described_class.verify_refresh_token(refresh_token.token)
      expect(result).to be_nil
    end
  end
end
