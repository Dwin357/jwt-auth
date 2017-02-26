describe JwtAuth::ValidateRequest do

	before do
		clear_cookies
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
		allow(logger).to receive(:info).and_call_original
	end

	let(:passed_app) { NullAppStub.new }

	context 'with a configured cookie_name' do
		let(:run_config) { {logger: logger, cookie_name: cookie_name} }

		describe 'an authorized request' do
			let(:app) { MockLogin.new(JwtAuth::ValidateRequest.new(passed_app)) }

			it 'notes authorization in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::validate-request: authorized')
				get request
			end
			it 'calls into passed app' do
				expect(passed_app).to receive(:call).and_call_original
				get request
			end
			it "sets JwtToken in session under '#{JwtAuth::ValidateRequest.new(nil).session_name}'" do
				get request
				expect(last_request.session).to have_key(app.app.session_name)
				expect(last_request.session[app.app.session_name])
					.to be_instance_of(JwtAuth::JwtToken)
			end
		end

		describe 'a request without a cookie' do
			let(:app) { JwtAuth::ValidateRequest.new(passed_app) }
			it 'notes unauthorization in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::validate-request: cookie not found')
				get request
			end
			it 'redirects to default target' do
				response = get request
				expect(response.status).to eq 302
				expect(response.location).to eq app.default_target
			end
		end

		describe 'a request with a tampered jwt' do
			let(:app) do
				MockJwt.new(
					JwtAuth::ValidateRequest.new(passed_app),
					{tampered_jwt: true}
				)
			end
			it 'notes unauthorized in log' do
				expect(logger).to receive(:info)
					.with('Jwt unauthorized, unrecognized sig, msg: JSON::JWS::VerificationFailed')
				get request
			end
			it 'redirects to default target' do
				response = get request
				expect(response.status).to eq 302
				expect(response.location).to eq app.app.default_target
			end
		end

		describe 'a request whose jwt signed w/ unknown key' do
			let(:app) do
				MockJwt.new(
					JwtAuth::ValidateRequest.new(passed_app),
					{unknown_signing_key: true}
				)
			end
			it 'notes unauthorized in log' do
				expect(logger).to receive(:info)
					.with('Jwt unauthorized, unrecognized sig, msg: JSON::JWS::VerificationFailed')
				get request
			end
			it 'redirects to default target' do
				response = get request
				expect(response.status).to eq 302
				expect(response.location).to eq app.app.default_target
			end
		end
		let(:cookie_name) { junk }
	end

	context 'with an unconfigured cookie_name' do
		let(:run_config) { {logger: logger} }

		describe 'an authorized request' do
			let(:app) { MockLogin.new(JwtAuth::ValidateRequest.new(passed_app)) }
			it 'notes authorization in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::validate-request: authorized')
				get request
			end
			it 'calls into passed app' do
				expect(passed_app).to receive(:call).and_call_original
				get request
			end
			it 'sets JwtToken in session under "jwt-user-data"' do
				get request
				expect(last_request.session).to have_key('jwt-user-data')
				expect(last_request.session['jwt-user-data'])
					.to be_instance_of(JwtAuth::JwtToken)
			end
			it "sets JwtToken in session under '#{JwtAuth::ValidateRequest.new(nil).session_name}'" do
				get request
				expect(last_request.session).to have_key(app.app.session_name)
				expect(last_request.session[app.app.session_name])
					.to be_instance_of(JwtAuth::JwtToken)
			end
		end

		describe 'a request without a cookie' do
			let(:app) { JwtAuth::ValidateRequest.new(passed_app) }
			it 'notes unauthorization in log' do
				expect(logger).to receive(:info)
					.with('jwt-auth::validate-request: cookie not found')
				get request
			end
			it 'redirects to default target' do
				response = get request
				expect(response.status).to eq 302
				expect(response.location).to eq app.default_target
			end
		end

		describe 'a request with a tampered jwt' do
			let(:app) do
				MockJwt.new(
					JwtAuth::ValidateRequest.new(passed_app),
					{tampered_jwt: true}
				)
			end
			it 'notes unauthorized in log' do
				expect(logger).to receive(:info)
					.with('Jwt unauthorized, unrecognized sig, msg: JSON::JWS::VerificationFailed')
				get request
			end
			it 'redirects to default target' do
				response = get request
				expect(response.status).to eq 302
				expect(response.location).to eq app.app.default_target
			end
		end

		describe 'a request whose jwt signed w/ unknown key' do
			let(:app) do
				MockJwt.new(
					JwtAuth::ValidateRequest.new(passed_app),
					{unknown_signing_key: true}
				)
			end
			it 'notes unauthorized in log' do
				expect(logger).to receive(:info)
					.with('Jwt unauthorized, unrecognized sig, msg: JSON::JWS::VerificationFailed')
				get request
			end
			it 'redirects to default target' do
				response = get request
				expect(response.status).to eq 302
				expect(response.location).to eq app.app.default_target
			end
		end
	end

	let(:logger) { NullLogger.new }
	let(:request) { junk_route }
end
