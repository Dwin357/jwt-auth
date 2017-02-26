describe JwtAuth::JwtToken do
	before do
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
	end

	let(:run_config) { {signing_key: shared_secret} }

	describe '.stamp_jwt' do
		subject { JwtAuth::JwtToken }
		it 'returns a signed JWT (ie JWS)' do
			expect(subject.stamp_jwt(passed_claims).class).to eq JSON::JWS
		end
		it 'carries claims passed by the user' do
			sample_jwt = subject.stamp_jwt(passed_claims)
			passed_claims.stringify_keys.each do |passed_key, passed_value|
				expect(sample_jwt[passed_key]).to eq passed_value
			end
		end
		it 'carries default claims' do
			sample_jwt = subject.stamp_jwt(passed_claims)
			JwtAuth::JwtToken.default_claims.stringify_keys.each do |key, _|
				expect(sample_jwt).to have_key(key)
				expect(sample_jwt[key]).not_to be_nil
			end
		end
	end

	describe 'JwtToken' do
		subject { JwtAuth::JwtToken.new(jwt_string) }
		it 'has readers for each passed claim' do
			token = subject
			passed_claims.each do |passed_key, passed_value|
				expect(token.send(passed_key)).to eq passed_value
			end
		end
		it 'has readers for each default claim' do
			token = subject
			JwtAuth::JwtToken.default_claims.each do |key, _|
				expect{ token.send(key) }.to_not raise_error
				expect(token.send(key)).to_not be_nil
			end
		end
	end

	let(:passed_claims) { {fnm: friendly_name, unm: user_name, uid: user_id} }
	let(:user_id) {  Random.rand(10_000) }
	let(:user_name) { junk }
	let(:friendly_name) { junk }
	let(:shared_secret) { junk }
	let(:jwt_string) { JwtAuth::JwtToken.stamp_jwt(passed_claims).to_s }
end
