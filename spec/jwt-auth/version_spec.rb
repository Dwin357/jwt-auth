describe 'version' do
	subject { JwtAuth::VERSION }

	it 'is 1.0.0' do
		expect(subject).to eq '1.0.0'
	end
end
