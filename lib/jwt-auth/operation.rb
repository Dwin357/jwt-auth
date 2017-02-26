module JwtAuth
	class Operation
		include LoggingConcerns
		include RedirectConcerns

		def initialize(_app)
			@app = _app
		end

		def call(_env)
			log :info, 'jwt-auth::operation: entering operation'
			@env          = _env
			@auth_request = AuthRequest.new(env)
			response      = delegate auth_request
			log :info, "jwt-auth::operation: exiting operation\n"
			response
		end

		private
		attr_reader :auth_request, :app, :env

		def delegate(auth_request)
			case
			when auth_request.excluded_path?
				log :info, 'jwt-auth::operation: excluded path'
				app.call(env)
			when auth_request.session_path?
				log :info, 'jwt-auth::operation: session path'
				SessionRequest.new(app).call(env)
			when auth_request.logout?
				log :info, 'jwt-auth::operation: logout path'
				LogoutRequest.new(app).call(env)
			when auth_request.token_present?
				log :info, 'jwt-auth::operation: found token'
				ValidateRequest.new(app).call(env)
			else
				log :info, 'jwt-auth::operation: default action'
				redirect_to(default_target)
			end
		end
	end
end
