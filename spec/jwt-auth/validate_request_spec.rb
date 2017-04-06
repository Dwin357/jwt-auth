describe JwtAuth::ValidateRequest do

	before do
		clear_cookies
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
		allow(logger).to receive(:info).and_call_original
	end

	let(:passed_app) { NullAppStub.new }

	context 'with a configured cookie_name and session name' do
		let(:run_config) do
			{logger: logger, cookie_name: cookie_name, session_name: session_name}
		end

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
			it "sets JwtToken in session under configured session_name" do
				get request
				expect(last_request.session).to have_key session_name
				expect(last_request.session[session_name])
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

		describe 'a request whose jwt is signed w/ unknown key' do
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
		let(:session_name) { junk }
	end

	context 'with a configured cookie_name and unconfigured session_name' do
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
			it "sets JwtToken in session under default name" do
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

		describe 'a request whose jwt is signed w/ unknown key' do
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

	context 'with an unconfigured cookie_name and configured session_name' do
		let(:run_config) { {logger: logger, session_name: session_name} }

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
			it 'sets JwtToken in session under configured name' do
				get request
				expect(last_request.session).to have_key session_name
				expect(last_request.session[session_name])
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

		describe 'a request whose jwt is signed by an unknown key' do
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
		let(:session_name) { junk }
	end

	context 'with an unconfigured cookie_name and session name' do
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
			it 'sets JwtToken in session under default session name' do
				get request
				expect(last_request.session).to have_key default_session_name
				expect(last_request.session[default_session_name])
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
	let(:default_session_name) do
		JwtAuth::Configuration.new.ensure_session_name_set
	end
end
