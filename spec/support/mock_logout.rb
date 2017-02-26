class MockLogout
	def initialize(_app)
		@app = _app
	end

	def call(env)
		mock_logout(env)
		app.call(env)
	end

	attr_reader :app

	def mock_logout(env)
		JwtAuth::LogoutRequest.new(app).call(env)
	end
end
