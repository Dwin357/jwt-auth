class TestLogger; include JwtAuth::LoggingConcerns; end

describe JwtAuth::LoggingConcerns do
	before { JwtAuth.config.logger = passed_logger }
	subject { TestLogger.new }

	describe '#log' do
		it 'passes level as method w/ msg as argument' do
			expect(passed_logger).to receive(level).with(message)
			subject.log level, message
		end
	end

	let(:level) { junk.to_sym }
	let(:passed_logger) { NullLogger.new }
	let(:message) { junk }

end
