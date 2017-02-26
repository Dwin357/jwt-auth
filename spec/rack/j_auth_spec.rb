describe Rack::JAuth do

	before { clear_config }

	describe 'new' do
		context 'with passed configuration' do
			let(:app) { Rack::JAuth.new(passed_app, passed_config)}
			let(:passed_config) { mandatory_config }
			it 'delegates to JwtAuth::Configuration with passed args' do
				expect_any_instance_of(JwtAuth::Configuration)
					.to receive(:assign).with(passed_config).and_call_original
				get request
			end
		end

		context 'without passed configuration' do
			let(:app) { Rack::JAuth.new(passed_app) }
			it 'passes {} which raises JwtAuth::Configuration::Error for missing mandatory config' do
				expect{ get request }.to raise_error(JwtAuth::Configuration::Error)
			end
		end
	end

	describe 'call' do
		let(:app) { Rack::JAuth.new(passed_app, mandatory_config) }
		it 'delegates to JwtAuth::Operation' do
			expect(JwtAuth::Operation).to receive(:new).with(passed_app).and_call_original
			expect_any_instance_of(JwtAuth::Operation).to receive(:call).and_call_original
			get request
		end
	end
	let(:request) { junk_route }
	let(:passed_app) { NullAppStub.new }
end
