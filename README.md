# Jwt Auth

A rack middle-ware gem designed to give a rails or rack app session behavior.  This gem will set a JWT into a cookie on the user's machine which includes information passed by the app upon a session path.  For any requests which are not explicitly excluded, the gem will parse that JWT and set that information into a session for the app to consume.

## Installation

Add this line to your gemfile:

```ruby
gem 'jwt-auth', git: ''

```

## Configuration

| setting									| Description						| Argument Format		|		Default									|
|-------------------------|-----------------------|-------------------|---------------------------|
| logger									| logger 								| an IO stream			| Rails - Rails.logger 			|
|													|												|										|	Rack - Logger.new(STDOUT)	|
| exclude_paths 					| unauthenticated path 	| *see path format	| *required 								|
| session_paths						| authorization path 		| *see path format	| *required 								|
| cookie_name 						| key for cookie 				| String 						| 'jwt-auth' 								|
| session_name 						| key for session 			| String 						| 'jwt-auth' 								|
| url_root 								| url root for website 	| String 						| '/' 											|
| default_redirect_target	| optional target 		 	| String 						| '' 												|
| signing_key 						| shared secret for JWT | String 						| *required 								|

### Path Format

```ruby
[ {route:~~, verb: 'post', params: {v: '1'}}, {route:~~, verb:'get', params:{user: '3'}}, ...]

```
Route is a required key which should be set to a string or regex matching the desired relative path.
Verb is an optional key which should be set to: 'get', 'post', 'put', 'patch', 'delete'
Params is an optional key which should be set to a hash of 1+ key:value pairs.  Params will be considered 'matching' if a request matches all passed parameters.

## Control Flow

### Exclude Path

#### Request

As Configured

#### Behavior

Passes along request regardless of presence of JWT cookie.  Does not set an accessible token in session even if cookie exists.

### Session Path

#### Request

As Configured

#### Behavior

Calls into app to authorize user.

##### Authorized User

App expects a json response

```ruby
{
	redirect_target: '/user/3',
	user_data: {
		atrib_1: value_1, # the attributes and values to be set in the users session w/ each request
		atrib_2: value_2
	}
}

```

##### Unauthorized User

App expects a 403 response.

### Logout Path

#### Request

url_root + '/logout'

#### Behavior

Deletes users cookie and session

### Authenticated Path

#### Request

Any request not matching a session or excluded path, or the logout path

#### Behavior

Verifies presence and authenticity of JWT in users cookie, and exposes information contained in the JWT via users session.
If verification fails, redirects user.

### Redirection

When the middleware encounters an unauthorized request, or after it logs a user out, it will redirect the user.
This redirect location, in order of precedence is
 1) configured default_redirect_target
 2) configured url_root
 3) '/' (ie default url_root)
