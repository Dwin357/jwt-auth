lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jwt-auth/version'

Gem::Specification.new do |spec|
	spec.name 		= 'jwt-auth'
	spec.version 	= JwtAuth::VERSION
	spec.authors  = ['Edwin Steinmetz']
	spec.email 		= ['e.r.steinmetz@gmail.com']
	spec.summary  = %q{This is a rack-middleware to authenticate based on json web tokens.}

	spec.add_dependency 'rack', '>= 1.5'
	spec.add_dependency 'json-jwt', '~> 1.5'
	spec.add_development_dependency 'bundler', '~> 1.10'
	spec.add_development_dependency 'byebug'
	spec.add_development_dependency 'rspec', '~> 3.0'
	spec.add_development_dependency 'rack-test', '~> 0.6'
end
