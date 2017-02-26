$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'jwt-auth'

Dir['./spec/support/**/*.rb'].each { |f| require f }

require 'byebug'
require 'rack/test'
require 'logger'

RSpec.configure do |config|
	config.order = :random
	config.include Rack::Test::Methods
	config.default_formatter = 'doc' if config.files_to_run.one?
end

def junk
	SecureRandom.uuid
end

def junk_route
	'/'+junk
end

def clear_config
	JwtAuth.config.settings.clear
end

def mandatory_config
	{
		session_paths: [junk_route],
		signing_key: junk,
		logger: NullLogger.new #not mandatory, but good for testing
	}
end
