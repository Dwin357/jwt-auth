module JwtAuth
	module RedirectConcerns
		include LoggingConcerns

		def redirect_to(target, status=302)
			log :info, "jwt-auth: redirect:#{target} status:#{status}"

			headers = {'Location'=>target, 'Content-Type'=>'text/plain'}
			body    = ['Redirecting you to '+target]
			Rack::Response.new(body, status, headers).finish
		end

		def default_target
			case
			when !JwtAuth.config.default_redirect_target.empty?
				JwtAuth.config.default_redirect_target
			else
				JwtAuth.config.url_root
			end
		end
	end
end
