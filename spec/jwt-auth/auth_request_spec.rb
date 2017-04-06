describe JwtAuth::AuthRequest do

	before do
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
	end

	let(:app) { NullAppStub.new }

	subject { JwtAuth::AuthRequest.new(last_request.env) }

	context 'with default root path' do

		describe '#excluded_path?' do
			before { send_entry_req(request_entry_arg) }
			context 'when request is excluded' do
				let(:run_config) { {exclude_paths: [request_entry_arg]} }
				it 'returns true' do
					expect(subject.excluded_path?).to be true
				end
			end
			context 'when request is not excluded' do
				let(:run_config) { {exclude_paths: []} }
				it 'returns false' do
					expect(subject.excluded_path?).to be false
				end
			end
		end

		describe '#session_path?' do
			before { send_entry_req(request_entry_arg) }
			context 'when request is a session path' do
				let(:run_config) { {session_paths:[request_entry_arg]} }
				it 'returns true' do
					expect(subject.session_path?).to be true
				end
			end
			context 'when request is not a session path' do
				let(:run_config) { {session_paths:[]} }
				it 'returns false' do
					expect(subject.session_path?).to be false
				end
			end
		end

		describe '#logout?' do
			let(:run_config) { {} }
			context 'when request is "/logout"' do
				before { get '/logout' }
				it 'returns true' do
					expect(subject.logout?).to be true
				end
			end
			context 'when request is not "/logout"' do
				before { send_entry_req(request_entry_arg) }
				it 'returns false' do
					expect(subject.logout?).to be false
				end
			end
		end

		describe '#token_present?' do
			let(:run_config) { {} }
			before { send_entry_req(request_entry_arg) }
			context 'with a set token' do
				let(:app) { MockLogin.new(NullAppStub.new) }
				it 'returns true' do
					expect(subject.token_present?).to be true
				end
			end
			context 'without a set tokent' do
				let(:app) { NullAppStub.new }
				it 'returns false' do
					expect(subject.token_present?).to be false
				end
			end
			context 'with a deleted token' do
				let(:app) { MockLogin.new(MockLogout.new(NullAppStub.new)) }
				it 'returns false' do
					expect(subject.token_present?).to be false
				end
			end
		end
	end

	context 'with assigned root path' do

		describe '#excluded_path?' do
			before { send_entry_req(request_entry_arg, root) }
			context 'when request is excluded' do
				let(:run_config) do
					{exclude_paths: [request_entry_arg], url_root: root}
				end
				it 'returns true' do
					expect(subject.excluded_path?).to be true
				end
			end
			context 'when request is not excluded' do
				let(:run_config) { {exclude_paths: [], url_root: root} }
				it 'returns false' do
					expect(subject.excluded_path?).to be false
				end
			end
		end

		describe '#session_path?' do
			before { send_entry_req(request_entry_arg, root) }
			context 'when request is a session path' do
				let(:run_config) do
					{session_paths:[request_entry_arg], url_root: root}
				end
				it 'returns true' do
					expect(subject.session_path?).to be true
				end
			end
			context 'when request is not a session path' do
				let(:run_config) { {session_paths:[], url_root: root} }
				it 'returns false' do
					expect(subject.session_path?).to be false
				end
			end
		end

		describe '#logout?' do
			let(:run_config) { {url_root: root} }
			context 'when request is "/logout"' do
				before { get (root+'/logout') }
				it 'returns true' do
					expect(subject.logout?).to be true
				end
			end
			context 'when request is not "/logout"' do
				before { send_entry_req(request_entry_arg, root) }
				it 'returns false' do
					expect(subject.logout?).to be false
				end
			end
		end

		describe '#token_present?' do
			let(:run_config) { {url_root: root} }
			before { send_entry_req(request_entry_arg, root) }
			context 'with a set token' do
				let(:app) { MockLogin.new(NullAppStub.new) }
				it 'returns true' do
					expect(subject.token_present?).to be true
				end
			end
			context 'without a set tokent' do
				let(:app) { NullAppStub.new }
				it 'returns false' do
					expect(subject.token_present?).to be false
				end
			end
			context 'with a deleted token' do
				let(:app) { MockLogin.new(MockLogout.new(NullAppStub.new)) }
				it 'returns false' do
					expect(subject.token_present?).to be false
				end
			end
		end
		let(:root) { junk_route }
	end

	let(:request_entry_arg) { junk_path_entry }

	def send_entry_req(entry, root=nil)
		if root
			send(entry[:verb], (root+entry[:route]), entry[:params])
		else
			send(entry[:verb], entry[:route], entry[:params])
		end
	end
end
