describe JwtAuth::LogoutRequest do

	before do
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
		allow(logger).to receive(:info).and_call_original
	end

	let(:app) do
		MockLogin.new(JwtAuth::LogoutRequest.new(nil))
	end

	context 'with a configured cookie_name' do
		let(:run_config) { {cookie_name: cookie_name, logger: logger} }

		it 'notes logout request in log' do
			expect(logger).to receive(:info)
				.with('jwt-auth::logout-request: logging user out')
			get '/logout'
		end
		it 'removes JwtAuth cookie' do
			get '/logout'
			expect(last_request.cookies).not_to have_key(cookie_name)
		end
		it 'does not remove other cookies' do
			get '/logout'
			expect(last_request.cookies).to have_key(app.someone_elses_cookie_name)
			expect(last_request.cookies[app.someone_elses_cookie_name])
				.to eq(app.someone_elses_cookie_value)
		end
		it 'redirects to default target' do
			response = get '/logout'
			expect(response.status).to eq 302
			expect(response.location).to eq app.app.default_target
		end
		let(:cookie_name) { junk }
	end

	context 'with a default cookie_name' do
		let(:run_config) { {logger: logger} }

		it 'notes logout request in log' do
			expect(logger).to receive(:info)
				.with('jwt-auth::logout-request: logging user out')
			get '/logout'
		end
		it 'removes JwtAuth cookie' do
			get '/logout'
			expect(last_request.cookies).not_to have_key(JwtAuth.config.cookie_name)
		end
		it 'does not remove other cookies' do
			get '/logout'
			expect(last_request.cookies).to have_key(app.someone_elses_cookie_name)
			expect(last_request.cookies[app.someone_elses_cookie_name])
				.to eq(app.someone_elses_cookie_value)
		end
		it 'redirects to default target' do
			response = get '/logout'
			expect(response.status).to eq 302
			expect(response.location).to eq app.app.default_target
		end
	end
	let(:logger) { NullLogger.new }
end
