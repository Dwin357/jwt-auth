class TestEnv; include JwtAuth::EnvConcerns; end

describe JwtAuth::EnvConcerns do
	before do
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
	end

	subject { TestEnv.new }

	describe '#cookie_name' do
		context 'with configured cookie name' do
			let(:run_config) { {cookie_name: configured_name} }
			it 'returns configured value' do
				expect(subject.cookie_name).to eq configured_name
			end
		end
		context 'with default cookie name' do
			let(:run_config) { {} }
			it "defaults to '#{JwtAuth::Configuration.new.ensure_cookie_name_set}'" do
				expect(subject.cookie_name).to eq default_cookie_name
			end
		end
	end

	describe '#session_name' do
		context 'with default session name' do
			let(:run_config) { {} }
			it "defaults to '#{JwtAuth::Configuration.new.ensure_session_name_set}'" do
				expect(subject.session_name).to eq default_session_name
			end
		end
		context 'with configured session name' do
			let(:run_config) { {session_name: configured_name} }
			it 'returns configured value' do
				expect(subject.session_name).to eq configured_name
			end
		end
	end

	let(:configured_name) { junk }
	let(:default_cookie_name) do
		JwtAuth::Configuration.new.ensure_cookie_name_set
	end
	let(:default_session_name) do
		JwtAuth::Configuration.new.ensure_session_name_set
	end
end
