module JwtAuth
	module LoggingConcerns
		def log(level, message)
			JwtAuth.config.logger.send(level, message)
		end
	end
end
