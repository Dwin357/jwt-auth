module JwtAuth
	class Railtie < Rails::Railtie
		config.jwt_auth = ActiveSupport::OrderedOptions.new

		initializer 'jwt_auth.initialize' do |app|
			require 'jwt-auth/rack/j_auth'
			app.middleware.use Rack::Auth, config.jwt_auth
		end
	end
end
