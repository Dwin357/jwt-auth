module JwtAuth
	class SessionRequest
		include LoggingConcerns
		include RedirectConcerns
		include EnvConcerns

		def initialize(_app)
			@app = _app
		end

		def call(_env)
			@env     = _env
			@request = Rack::Request.new(env)
			log :info, 'jwt-auth::session-request: call into app'
			status, headers, body = app.call(env)
			authorized?(status) ? authorize(body) : reject
		end


		private
		attr_reader :app, :env, :request

		def authorize(response_details)
			log :info, 'jwt-auth::session-request: authorized'
			info = JSON.parse(response_details.body[0])
			request.cookies[cookie_name] = JwtToken.stamp_jwt(info['user_data']).to_s
			redirect_to info['redirect_target']
		end

		def reject
			log :info, 'jwt-auth::session-request: unauthorized'
			redirect_to default_target
		end

		def authorized?(status)
			status == 302
		end
	end
end
