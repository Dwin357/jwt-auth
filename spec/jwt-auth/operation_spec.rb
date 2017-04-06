describe JwtAuth::Operation do

	before do
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
		allow(logger).to receive(:info).and_call_original
	end

	let(:app) { JwtAuth::Operation.new(passed_app) }

	describe 'requests an excluded path' do
		let(:run_config) { {logger: logger, exclude_paths: [request_entry]} }

		it 'logs entering the operation' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: entering operation')
			send_request(request_entry)
		end
		it 'logs exiting the operation' do
			expect(logger).to receive(:info)
				.with("jwt-auth::operation: exiting operation\n")
			send_request(request_entry)
		end
		it 'logs exclusion branch' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: excluded path')
			send_request(request_entry)
		end
		it 'calls into passed app' do
			expect(passed_app).to receive(:call).and_call_original
			send_request(request_entry)
		end
		let(:passed_app) { NullAppStub.new }
	end

	describe 'requests a session path' do
		before do
			allow(passed_app).to receive(:call)
				.and_return(passed_app.authorized_response)
		end
		let(:run_config) { {logger: logger, session_paths:[request_entry]} }
		it 'logs entering the operation' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: entering operation')
			send_request(request_entry)
		end
		it 'logs exiting the operation' do
			expect(logger).to receive(:info)
				.with("jwt-auth::operation: exiting operation\n")
			send_request(request_entry)
		end
		it 'logs session branch' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: session path')
			send_request(request_entry)
		end
		it 'delegates to SessionRequest' do
			expect(JwtAuth::SessionRequest).to receive(:new)
				.with(passed_app).and_call_original
			expect_any_instance_of(JwtAuth::SessionRequest)
				.to receive(:call).and_call_original
			send_request(request_entry)
		end
		let(:passed_app) { SessionAppStub.new }
	end

	describe 'requests a logout path' do
		let(:run_config) { {logger: logger} }
		it 'logs entering the operation' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: entering operation')
			get '/logout'
		end
		it 'logs exiting the operation' do
			expect(logger).to receive(:info)
				.with("jwt-auth::operation: exiting operation\n")
			get '/logout'
		end
		it 'logs logout branch' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: logout path')
			get '/logout'
		end
		it 'delegates to LogoutRequest' do
			expect(JwtAuth::LogoutRequest).to receive(:new)
				.with(passed_app).and_call_original
			expect_any_instance_of(JwtAuth::LogoutRequest)
				.to receive(:call).and_call_original
			get '/logout'
		end
		let(:passed_app) { NullAppStub.new }
	end

	describe 'requests a validate path' do
		let(:run_config) { {logger: logger} }
		let(:app) { MockLogin.new(JwtAuth::Operation.new(passed_app)) }
		it 'logs entering the operation' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: entering operation')
			send_request
		end
		it 'logs exiting the operation' do
			expect(logger).to receive(:info)
				.with("jwt-auth::operation: exiting operation\n")
			send_request
		end
		it 'logs found token branch' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: found token')
			send_request
		end
		it 'delegates to ValidateRequest' do
			expect(JwtAuth::ValidateRequest).to receive(:new)
				.with(passed_app).and_call_original
			expect_any_instance_of(JwtAuth::ValidateRequest)
				.to receive(:call).and_call_original
			send_request
		end
		let(:passed_app) { NullAppStub.new }
	end

	describe 'request defaults' do
		let(:run_config) { {logger: logger} }
		it 'logs entering the operation' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: entering operation')
			send_request
		end
		it 'logs exiting the operation' do
			expect(logger).to receive(:info)
				.with("jwt-auth::operation: exiting operation\n")
			send_request
		end
		it 'logs default action branch' do
			expect(logger).to receive(:info)
				.with('jwt-auth::operation: default action')
			send_request
		end
		it 'redirects to default target' do
			response = send_request
			expect(response.status).to eq 302
			expect(response.location).to eq app.default_target
		end
		let(:passed_app) { NullAppStub.new }
	end

	let(:logger) { NullLogger.new }
	# let(:logger) { Logger.new('log-scratch.txt') }
	let(:request_entry) { junk_path_entry }

	def send_request(entry = junk_path_entry)
		send(entry[:verb], entry[:route], entry[:params])
	end
end
