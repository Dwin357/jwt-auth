class MockJwt
	include JwtAuth::EnvConcerns

	def initialize(_app, _options={})
		@app = _app
		@options = _options
	end

	def call(env)
		mock_login(env)
		apply_options(env)
		app.call(env)
	end

	attr_reader :app, :options

	def mock_login(env)
		MockLogin.new(NullAppStub.new).call(env)
	end

	def apply_options(env)
		options.each do |name, apply|
			self.send(name, env) if apply
		end
	end

	def unknown_signing_key(env)
		stash = JwtAuth.config.signing_key
		JwtAuth.config.signing_key = bogus_signing_key
		mock_login(env)
		JwtAuth.config.signing_key = stash
	end

	def tampered_jwt(env)
		request = Rack::Request.new(env)
		original_jwt_string = request.cookies[cookie_name]
		bogus_jwt_string    = JwtAuth::JwtToken.stamp_jwt(bogus_claims).to_s

		b_header, b_body, b_signature = bogus_jwt_string.split('.')
		o_header, o_body, o_signature = original_jwt_string.split('.')

		request.cookies[cookie_name] = [o_header, b_body, o_signature].join('.')
	end

	def bogus_claims
		{ user_id: 666, friendly_name: 'joker' }
	end

	def bogus_signing_key
		'not_shared_secret'
	end
end
