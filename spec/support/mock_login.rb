class MockLogin
	def initialize(_app)
		@app = _app
	end

	def call(env)
		mock_login(env)
		set_someone_elses_cookie(env)
		app.call(env)
	end

	attr_reader :app

	def mock_login(env)
		stash = env['PATH_INFO']
		env['PATH_INFO'] = '/authorized'
		JwtAuth::SessionRequest.new(SessionAppStub.new).call(env)
		env['PATH_INFO'] = stash
	end

	def set_someone_elses_cookie(env)
		Rack::Request.new(env)
			.cookies[someone_elses_cookie_name] = someone_elses_cookie_value
	end

	def someone_elses_cookie_name
		'awsome-site'
	end

	def someone_elses_cookie_value
		'bam'
	end
end
