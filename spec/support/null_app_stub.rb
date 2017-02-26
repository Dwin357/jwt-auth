class NullAppStub
	def call(env)
		request = Rack::Request.new(env)
		case
		when request.path.ends_with?('/success')
			success_response
		else
			success_response
		end
	end

	def success_response
		response(302)
	end

	def response(status)
		body    = ['']
		headers = {}
		Rack::Response.new(body, status, headers).finish
	end
end
