class Rack::JAuth

	def initialize(_app, config={})
		@app = _app
		JwtAuth.config.assign config
	end

	def call(env)
		dup.call!(env)
	end

	def call!(env)
		JwtAuth::Operation.new(app).call(env)
	end

	private
	attr_reader :app
end
