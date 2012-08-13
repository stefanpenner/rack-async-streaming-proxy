require 'uri'

module FrontendProxy
  autoload :AsyncStreamingBody, 'frontend_proxy/async_streaming_body'
  autoload :Configuration, 'frontend_proxy/configuration'
  autoload :AddHeader,   'frontend_proxy/add_header'
  autoload :Rack,   'frontend_proxy/rack'
  autoload :Util,   'frontend_proxy/util'
end
