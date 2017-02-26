module JwtAuth
	class JwtToken

		class << self
			def stamp_jwt(claims)
				JSON::JWT.new(jwt_claims(claims)).sign(signing_key, :HS512)
			end

			def signing_key
				JwtAuth.config.signing_key
			end

			def jwt_claims(passed_values)
				default_claims.merge(passed_values)
			end

			def default_claims
				{
					jti: SecureRandom.uuid,
					created: Time.now
				}
			end
		end

		def initialize(jwt_string)
			@token  = JSON::JWT.decode(jwt_string, JwtToken.signing_key)
			define_claim_readers
		end

		private
		attr_reader :token

		def define_claim_readers
			token.each do |key, value|
				define_singleton_method(key.to_sym) { token[key] }
			end
		end

	end
end
