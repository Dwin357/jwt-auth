describe JwtAuth::Configuration do
	subject { JwtAuth::Configuration.new.assign(settings_hash) }

	context 'when an unrecognized attribute passed' do
		let(:settings_hash) { passed_settings.merge({ bad_key => junk }) }
		it 'raises a JwtAuth::Configuration::Error' do
			expect{ subject }.to raise_error { JwtAuth::Configuration::Error }
		end
	end

	context 'when values passed in' do
		let(:settings_hash) { passed_settings }
		it 'uses passed in settings' do
			passed_settings.each do |key, value|
				expect(subject.send(key)).to eq value
			end
		end
	end

	context 'non-manditory attributes' do
		let(:settings_hash) { manditory_settings }

		describe 'default logger' do
			context 'in a non-rails environment' do
				it 'uses ruby Logger' do
					expect(subject.logger.class).to eq Logger
				end
			end
			context 'in a rails environment' do
				before do
					stub 'Rails'
					allow(Rails).to receive(:logger).and_return(rails_logger_standin)
				end
				it 'uses rails logger' do
					expect(subject.logger).to eq(rails_logger_standin)
				end
			end
		end

		describe 'default exclusion paths' do
			it 'no excluded paths' do
				expect(subject.exclude_paths).to eq ['']
			end
		end

		describe 'default url root' do
			it '/' do
				expect(subject.url_root).to eq '/'
			end
		end

		describe 'default cookie name' do
			it 'jwt-auth' do
				expect(subject.cookie_name).to eq 'jwt-auth'
			end
		end

		describe 'default redirect target' do
			it 'empty string' do
				expect(subject.default_redirect_target).to eq ''
			end
		end
	end

	context 'manditory attributes' do
		context 'missing a session_paths' do
			before { manditory_settings.delete(:session_paths) }
			it 'raises a configuration error' do
				expect{ subject }.to raise_error{ JwtAuth::Configuration::Error }
			end
		end
		context 'missing signing_key' do
			before { manditory_settings.delete(:signing_key) }
			it 'raises a configuration error' do
				expect{ subject }.to raise_error{ JwtAuth::Configuration::Error }
			end
		end
	end

	describe 'special behavior' do
		describe 'url root' do
			context 'url root setting passed w/out pre-pending slash' do
				let(:bad_form) { junk }
				let(:settings_hash) { manditory_settings.merge({ url_root: bad_form }) }
				it 'adds prepending slash' do
					expect(subject.url_root).to eq('/' + bad_form)
				end
			end
		end
	end

	let(:manditory_settings) do
		{
			session_paths: sample_session_paths,
			signing_key: sample_signing_key
		}
	end

	let(:passed_settings) do
		{
			logger: sample_logger,
			exclude_paths: sample_exclude_paths,
			session_paths: sample_session_paths,
			url_root: sample_url_root,
			cookie_name: sample_cookie_name,
			default_redirect_target: sample_default_redirect_target,
			signing_key: sample_signing_key
		}
	end

	let(:bad_key) { junk.to_sym }
	let(:rails_logger_standin) { junk }
	let(:sample_logger) { junk }
	let(:sample_exclude_paths) { ['/login/new', '/users/new'] }
	let(:sample_session_paths) { ['/login', '/users'] }
	let(:sample_url_root) { junk_route }
	let(:sample_cookie_name) { junk }
	let(:sample_default_redirect_target) { junk_route }
	let(:sample_signing_key) { junk }

	def stub(stubbie)
		stub_const stubbie, Class.new
	end
end
