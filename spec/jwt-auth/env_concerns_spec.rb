class TestEnv; include JwtAuth::EnvConcerns; end

describe JwtAuth::EnvConcerns do
	before do
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
	end

	subject { TestEnv.new }

	describe '#cookie_name' do
		context 'with configured cookie name' do
			let(:run_config) { {cookie_name: name} }
			it 'returns configured value' do
				expect(subject.cookie_name).to eq name
			end
			let(:name) { junk }
		end
		context 'with default cookie name' do
			let(:run_config) { {} }
			it 'defaults to "jwt-auth"' do
				expect(subject.cookie_name).to eq 'jwt-auth'
			end
		end
	end

	describe '#session_name' do
		let(:run_config) { {} }
		it "defaults to 'jwt-user-data'" do
			expect(subject.session_name).to eq 'jwt-user-data'
		end
	end
end
