module JwtAuth
	module EnvConcerns
		def cookie_name
			JwtAuth.config.cookie_name
		end

		def session_name
			JwtAuth.config.session_name
		end
	end
end
