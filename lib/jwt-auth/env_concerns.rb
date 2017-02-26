module JwtAuth
	module EnvConcerns
		def cookie_name
			JwtAuth.config.cookie_name
		end

		def session_name
			'jwt-user-data'
		end
	end
end
