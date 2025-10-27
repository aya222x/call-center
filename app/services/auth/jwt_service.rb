module Auth
  class JwtService
      SECRET_KEY = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base

      # Encode payload into JWT token
      # @param payload [Hash] Data to encode
      # @param exp [Time] Expiration time (default: 24 hours from now)
      # @return [String] JWT token
      def self.encode(payload, exp = 24.hours.from_now)
        payload = payload.dup
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY, "HS256")
      end

      # Encode JWT token for a specific user (includes password_version)
      # @param user [User] The user to generate token for
      # @param exp [Time] Expiration time (default: 24 hours from now)
      # @return [String] JWT token
      def self.encode_for_user(user, exp = 24.hours.from_now)
        encode({
          user_id: user.id,
          password_version: user.password_version
        }, exp)
      end

      # Decode JWT token
      # @param token [String] JWT token to decode
      # @return [Hash, nil] Decoded payload or nil if invalid/expired
      def self.decode(token)
        decoded = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")[0]
        HashWithIndifferentAccess.new(decoded)
      rescue JWT::DecodeError, JWT::ExpiredSignature => e
        nil
      end

      # Generate a refresh token for a user
      # @param user [User] The user to generate token for
      # @return [Hash] { token: String, refresh_token: RefreshToken }
      def self.generate_refresh_token(user)
        refresh_token = RefreshToken.new(
          user: user,
          expires_at: 30.days.from_now
        )
        refresh_token.generate_token
        refresh_token.save!

        {
          token: refresh_token.token,
          refresh_token: refresh_token
        }
      end

      # Verify a refresh token
      # @param token_string [String] The plain refresh token
      # @return [RefreshToken, nil] The refresh token record if valid, nil otherwise
      def self.verify_refresh_token(token_string)
        return nil if token_string.blank?

        # Find all active refresh tokens and check each one
        RefreshToken.active.find_each do |refresh_token|
          begin
            if BCrypt::Password.new(refresh_token.token_digest) == token_string
              return refresh_token
            end
          rescue BCrypt::Errors::InvalidHash
            next
          end
        end

        nil
      end
  end
end
