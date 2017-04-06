describe JwtAuth::PathEntryCollection do

	before do
		clear_config
		JwtAuth.config.assign(mandatory_config)
	end

	describe 'object creation' do
		subject { JwtAuth::PathEntryCollection.new(run_args) }

		context 'with valid arguments' do
			let(:run_args) { [junk_path_entry, junk_path_entry] }
			it 'returns a PathEntryCollection' do
				expect(subject).to be_an_instance_of(JwtAuth::PathEntryCollection)
			end
		end
		context 'with invalid arguments' do
			context 'with un-iterable arguments' do
				let(:run_args) { junk_route }
				it 'raises a JwtAuth::PathEntryCollection::Error' do
					expect{ subject }.to raise_error JwtAuth::PathEntryCollection::Error
				end
			end
			context 'when PathEntry doesnt like collections arg' do
				let(:run_args) do
					bad_arg = junk_path_entry
					bad_arg.delete(:route)
					[bad_arg, junk_path_entry]
				end
				it 'raises a JwtAuth::PathEntry::Error' do
					expect{ subject }.to raise_error JwtAuth::PathEntry::Error
				end
			end
		end
	end

	describe '#include?' do
		before do
			send(request_entry[:verb], request_entry[:route], request_entry[:params])
		end
		subject do
			JwtAuth::PathEntryCollection.new(config_args).include?(last_request)
		end

		context 'request matches one PathEntry' do
			let(:config_args) { [request_entry, junk_path_entry] }
			it 'true' do
				expect(subject).to be true
			end
		end
		context 'request matches multiple PathEntrys' do
			let(:config_args) { [request_entry, request_entry] }
			it 'true' do
				expect(subject).to be true
			end
		end
		context 'request doesnt match any PathEntrys' do
			let(:config_args) { [junk_path_entry, junk_path_entry] }
			it 'false' do
				expect(subject).to be false
			end
		end
		let(:request_entry) { junk_path_entry }
		let(:app) { NullAppStub.new }
		# def root_path(req_arg)
		# 	root + req_arg[:route]
		# end
	end

	describe '#empty?' do
		subject { JwtAuth::PathEntryCollection.new(arg).empty? }

		context 'with elements in collection' do
			let(:arg) {  [junk_path_entry, junk_path_entry] }
			it 'false' do
				expect(subject).to be false
			end
		end
		context 'without elements in collection' do
			let(:arg) {  [] }
			it 'true' do
				expect(subject).to be true
			end
		end
	end

	describe 'JwtAuth::PathEntryCollection::Error' do
		subject { raise JwtAuth::PathEntryCollection::Error }
		it 'can be recognized as JwtAuth::Configuration::Error' do
			expect{ subject }.to raise_error JwtAuth::Configuration::Error
		end
	end
end
