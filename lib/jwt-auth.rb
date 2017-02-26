# std lib
require 'json'

# gems
require 'rack'
require 'json/jwt'

# project files
require 'jwt-auth/railtie' if defined?(Rails)
require 'jwt-auth/version'
require 'jwt-auth/logging_concerns'
require 'jwt-auth/redirect_concerns'
require 'jwt-auth/env_concerns'

require 'jwt-auth/configuration'
require 'jwt-auth/auth_request'
require 'jwt-auth/jwt_token'

require 'jwt-auth/session_request'
require 'jwt-auth/logout_request'
require 'jwt-auth/validate_request'
require 'jwt-auth/operation'

require 'jwt-auth/rack/j_auth'

module JwtAuth
	def self.configure
		yield config
	end

	def self.config
		@config ||= Configuration.new
	end
end
