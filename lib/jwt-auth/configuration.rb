module JwtAuth
	class Configuration
		class Error < StandardError; end

		LEGAL_SETTINGS = %i(
			logger
			exclude_paths
			session_paths
			url_root
			cookie_name
			default_redirect_target
			signing_key
		)

		LEGAL_SETTINGS.each do |setting|
			define_method(setting) { @settings[setting] }
			define_method("#{setting}=") { |value| @settings[setting] = value }
		end

		def initialize
			@settings = {}
		end

		def assign(settings_hash)
			settings_hash.each do |key, value|
				raise Error, "invalid setting #{key}" unless LEGAL_SETTINGS.include? key
				settings[key] = value
			end
			LEGAL_SETTINGS.each { |setting| send "ensure_#{setting}_set" }
			self
		end

		def ensure_session_paths_set
			case
			when settings.include?(:session_paths)
				nil
			else
				raise Error, 'session_paths must be assigned.'
			end
		end

		def ensure_signing_key_set
			case
			when settings.include?(:signing_key)
				nil
			else
				raise Error, 'shared secret signing_key must be assigned'
			end
		end

		def ensure_cookie_name_set
			case
			when settings.include?(:cookie_name)
				nil
			else
				settings[:cookie_name] = 'jwt-auth'
			end
		end

		def ensure_url_root_set
			case
			when settings.include?(:url_root)
				settings[:url_root] = File.join('/', settings[:url_root])
			else
				settings[:url_root] = '/'
			end
		end

		def ensure_logger_set
			case
			when settings.include?(:logger)
				nil
			when defined? Rails
				settings[:logger] = Rails.logger
			else
				require 'logger'
				settings[:logger] = Logger.new(STDOUT)
			end
		end

		def ensure_exclude_paths_set
			case
			when settings.include?(:exclude_paths)
				nil
			else
				settings[:exclude_paths] = ['']
			end
		end

		def ensure_default_redirect_target_set
			case
			when settings.include?(:default_redirect_target)
				nil
			else
				settings[:default_redirect_target] = ''
			end
		end

		attr_reader :settings
	end
end
