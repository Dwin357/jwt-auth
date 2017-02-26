class SessionAppStub

	def call(env)
		request = Rack::Request.new(env)
		case
		when request.path == '/unauthorized'
			return unauthorized_response
		when request.path == '/authorized'
			return authorized_response
		else
			raise StandardError, 'SessionApp stub not configured for this request path'
		end
	end

	def authorized_response
		status  = 302
		headers = { 'Content-Type' => 'application/json' }
		body    = [ response_json ]
		response(status, body, headers)
	end

	def unauthorized_response
		status  = 403
		headers = { 'Content-Type' => 'text/plain' }
		body    = [ 'Unauthorized user' ]
		response(status, body, headers)
	end

	def response(status, body, headers)
		Rack::Response.new(body, status, headers).finish
	end

	def response_json
		{
			redirect_target: '/user/3',
			user_data: { user_id: 3, friendly_name: 'batman' }
		}.to_json
	end
end
