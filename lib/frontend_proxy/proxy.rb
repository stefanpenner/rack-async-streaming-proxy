require 'http/parser' # gem install http_parser.rb
require 'uuid'        # gem install uuid

module FrontendProxy
  module Proxy
    extend self

    def run
      Configuration.log_summary

      ::Proxy.start(Configuration.for(:proxy)) do |conn|

        @p = Http::Parser.new
        @buffer = ''

        @p.on_headers_complete = proc do |h|

          url = @p.request_url

          # this could be made to support N proxies
          namespace = url =~ /\/api\/(.*)/ ? :api : :app

          config = Configuration.for(namespace)

          if namespace == :api
            Util.rewrite!(@buffer,config)
            Util.authenticate!(@buffer,config)
          end

          conn.server UUID.generate, config

          conn.relay_to_servers @buffer

          @buffer.clear
        end

        conn.on_data do |data|
          @buffer << data
          @p << data
        end
      end
    end
  end
end
