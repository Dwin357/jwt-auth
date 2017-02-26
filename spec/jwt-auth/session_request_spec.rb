describe JwtAuth::SessionRequest do

	before do
		clear_cookies
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
		allow(logger).to receive(:info).and_call_original
	end

	let(:app) { JwtAuth::SessionRequest.new(SessionAppStub.new) }

	context 'with a configured cookie_name' do
		let(:run_config) { {cookie_name: cook, logger: logger} }

		describe 'an authorized request' do
			it 'sets jwt string in cookie' do
				get '/authorized'
				expect(last_request.cookies[JwtAuth.config.cookie_name])
					.to match(jwt_string_pattern)
			end
			it 'creates JwtToke with user data' do
				expect(JwtAuth::JwtToken).to receive(:stamp_jwt)
					.with(response_stub_details['user_data'])
				get '/authorized'
			end
			it 'sets cookie under configured name' do
				get '/authorized'
				expect(last_request.cookies[JwtAuth.config.cookie_name]).not_to be_nil
			end
			it 'notes autorization in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::session-request: authorized')
				get '/authorized'
			end
			it 'notes session request in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::session-request: call into app')
				get '/authorized'
			end
			it 'redirects to target' do
				response = get '/authorized'
				expect(response.status).to eq 302
				expect(response.location).to eq response_stub_details['redirect_target']
			end
			let(:response_stub_details) do
				JSON.parse(SessionAppStub.new.response_json)
			end
		end

		describe 'an unauthorized request' do
			it 'does not set cookie' do
				get '/unauthorized'
				expect(last_request.cookies[JwtAuth.config.cookie_name]).to be_nil
			end
			it 'notes session request in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::session-request: call into app')
				get '/unauthorized'
			end
			it 'notes unauthorization in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::session-request: unauthorized')
				get '/unauthorized'
			end
			it 'redirects to default target' do
				response = get '/unauthorized'
				expect(response.status).to eq 302
				expect(response.location).to eq app.default_target
			end
		end

		let(:cook) { junk }
	end

	context 'with an unconfigured cookie_name' do
		let(:run_config) { {logger: logger} }

		describe 'an authorized request' do
						it 'sets jwt string in cookie' do
				get '/authorized'
				expect(last_request.cookies[JwtAuth.config.cookie_name])
					.to match(jwt_string_pattern)
			end
			it 'creates JwtToke with user data' do
				expect(JwtAuth::JwtToken).to receive(:stamp_jwt)
					.with(response_stub_details['user_data'])
				get '/authorized'
			end
			it 'sets cookie under default name' do
				get '/authorized'
				expect(last_request.cookies[JwtAuth.config.cookie_name]).not_to be_nil
			end
			it 'notes autorization in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::session-request: authorized')
				get '/authorized'
			end
			it 'notes session request in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::session-request: call into app')
				get '/authorized'
			end
			it 'redirects to target' do
				response = get '/authorized'
				expect(response.status).to eq 302
				expect(response.location).to eq response_stub_details['redirect_target']
			end
			let(:response_stub_details) do
				JSON.parse(SessionAppStub.new.response_json)
			end
		end

		describe 'an unauthorized request' do
			it 'does not set cookie' do
				get '/unauthorized'
				expect(last_request.cookies[JwtAuth.config.cookie_name]).to be_nil
			end
			it 'notes session request in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::session-request: call into app')
				get '/unauthorized'
			end
			it 'notes unauthorization in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::session-request: unauthorized')
				get '/unauthorized'
			end
			it 'redirects to default target' do
				response = get '/unauthorized'
				expect(response.status).to eq 302
				expect(response.location).to eq app.default_target
			end
		end
	end

	let(:logger) { NullLogger.new }
	# let(:logger) { Logger.new('log-scratch.txt') }
	let(:jwt_string_pattern) { /.+\..+\..+/ }
end
