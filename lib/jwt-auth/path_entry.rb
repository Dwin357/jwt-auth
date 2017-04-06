module JwtAuth
	class PathEntry

		class Error < Configuration::Error; end

		def initialize(path_entry_arg)
			validate path_entry_arg
			@route  = path_entry_arg[:route]
			@verb   = path_entry_arg[:verb] if path_entry_arg[:verb]
			@params = path_entry_arg[:params] if path_entry_arg[:params]
		end

		def match?(request)
			return false unless match_route?(request)
			return false unless guarded_match_verb?(request)
			return false unless guarded_match_params?(request)
			true
		end

		private
		attr_reader :verb, :params

		def guarded_match_verb?(request)
			verb ? match_verb?(request) : true
		end

		def guarded_match_params?(request)
			params ? match_params?(request) : true
		end

		def match_route?(request)
			request.path == route
		end

		def route
			File.join(JwtAuth.config.url_root, @route)
		end

		def match_verb?(request)
			request.request_method.downcase.to_sym == verb
		end

		def match_params?(request)
			# this is kind of stupid
			# in params  the key is :"key"
			# in request the key is "key"
			# note one is a symbol, one is a string, but the sym has the quotes in it
			evaluated_keys = params.keys
			considered_params = request.params.slice(*evaluated_keys.map(&:to_s))

			return false unless considered_params.count == evaluated_keys.count
			evaluated_keys.each do |key|
				return false unless params[key] == considered_params[key.to_s]
			end
			true
		end

		def validate(path_entry_arg)
			case
			when !valid_route?(path_entry_arg)
				msg = 'invalid or missing route'
				raise Error, msg
			when !valid_verb?(path_entry_arg)
				msg = 'invalid verb'
				raise Error, msg
			when !valid_params?(path_entry_arg)
				msg = 'invalid params'
				raise Error, msg
			else
				true
			end
		end

		def valid_route?(path_entry_arg)
			path_entry_arg.has_key?(:route) &&
			path_entry_arg[:route] &&
			!path_entry_arg[:route].empty?
		end

		def valid_verb?(path_entry_arg)
			valid_verbs = ['get', 'post', 'put', 'patch', 'delete']
			if path_entry_arg[:verb]
				return false unless valid_verbs.include?(path_entry_arg[:verb].to_s.downcase)
			end
			true
		end

		def valid_params?(path_entry_arg)
			if path_entry_arg[:params]
				return false unless path_entry_arg[:params].respond_to?(:each)
				path_entry_arg[:params].each do |k, v|
					return false unless (k && v)
				end
			end
			true
		end

	end
end
