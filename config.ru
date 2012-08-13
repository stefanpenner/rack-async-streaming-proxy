require 'rubygems'
require 'eventmachine'
require 'em-http-request'
require 'http/parser'
require 'rack'
$:.unshift './lib'
require 'frontend_proxy'

map '/api' do
  use FrontendProxy::AddHeader, 'X-Radium-Developer-API-Key', '85014bb4d29fd1423a55b1779acbdc96a0d82989'
  use FrontendProxy::AddHeader, 'HTTP_X_RADIUM_USER_API_KEY', '6ac5d79050dab2853832a588d698693e8528567a'
  use FrontendProxy::Rack, host: 'http://cachefly.cachefly.net'
end

run lambda {|env| [200, {'Content-Type' => 'text/html'}, ["Hello World!?"]]}
