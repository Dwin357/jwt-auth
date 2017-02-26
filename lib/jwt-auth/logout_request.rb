module JwtAuth
	class LogoutRequest
		include LoggingConcerns
		include RedirectConcerns
		include EnvConcerns

		def initialize(app)
		end

		def call(env)
			@request = Rack::Request.new(env)
			logout_user
		end

		private
		attr_reader :request

		def logout_user
			log :info, 'jwt-auth::logout-request: logging user out'
			request.cookies.delete(cookie_name)
			redirect_to default_target
		end
	end
end
