module JwtAuth
	class ValidateRequest
		include LoggingConcerns
		include RedirectConcerns
		include EnvConcerns

		def initialize(_app)
			@app = _app
		end

		def call(_env)
			@env     = _env
			@request = Rack::Request.new(env)
			authorized? ? pass_along : reject
		end

		private
		attr_reader :app, :env, :request, :jwt

		def authorized?
			case
			when request.cookies[cookie_name].nil?
				log :info, 'jwt-auth::validate-request: cookie not found'
				return false
			when request.cookies[cookie_name].empty?
				log :info, 'JwtAuth cookie empty'
				return false
			when authorized_jwt?(request.cookies[cookie_name])
				return true
			else
				false
			end
		end

		def authorized_jwt?(jwt_string)
			JSON::JWT.decode(jwt_string, JwtAuth.config.signing_key)
			true

			rescue JSON::JWS::VerificationFailed => e
				log :info, "Jwt unauthorized, unrecognized sig, msg: #{e.message}"
				false
			rescue JSON::JWT::Exception => e
				log :info, "Jwt unauthorized, tampered with, msg:#{e.message}"
				false
		end

		def set_jwt_in_session
			request.session[session_name] = JwtToken.new(request.cookies[cookie_name])
		end

		def pass_along
			log :info, 'jwt-auth::validate-request: authorized'
			set_jwt_in_session
			app.call(env)
		end

		def reject
			redirect_to default_target
		end
	end
end
