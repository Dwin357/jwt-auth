module JwtAuth
	class AuthRequest
		include EnvConcerns

		def initialize(env)
			@request = Rack::Request.new(env)
		end

		def excluded_path?
			root_excluded_paths.include? request.path_info
		end

		def session_path?
			root_session_paths.include? request.path_info
		end

		def logout?
			request.path_info == append_to_root('/logout')
		end

		def token_present?
			return false if token.nil?
			return false if token.empty?
			true
		end

		private
		attr_reader :request

		def append_to_root(path)
			File.join(JwtAuth.config.url_root, path)
		end

		def root_excluded_paths
			JwtAuth.config.exclude_paths.map{ |path| append_to_root(path) }
		end

		def root_session_paths
			JwtAuth.config.session_paths.map{ |path| append_to_root(path) }
		end

		def token
			request.cookies[cookie_name]
		end
	end
end
