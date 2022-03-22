# frozen_string_literal: true

module UffizziCore::TokenService
  class << self
    def encode(payload)
      JWT.encode(payload, Settings.rails.secret_key_base, 'HS256')
    end

    def decode(token)
      JWT.decode(token, Settings.rails.secret_key_base, true, algorithm: 'HS256')
    rescue JWT::DecodeError
      nil
    end

    def generate
      SecureRandom.hex
    end
  end
end
