module FrontendProxy
  class Rack < EM::Connection

    def error!
      close_connection_after_writing
    end

    def done!
      close_connection_after_writing
    end

    def stream!(data)
      send_data data
    end

    def post_init
    end

    def initialize(options)
      @full_host = options.fetch(:host)
      @full_host =~ /(https?:\/\/)(.*)\//
      @protocol, @host = $1 , $2
    end

    def call(env={})

      path = env.fetch('PATH_INFO')
      http_method = env.fetch('REQUEST_METHOD').downcase

      headers = FrontendProxy::Util.derackify(env)
      # extract headers
      headers["HOST"] = @host

      # build url
      url = @full_host + path

      EM.next_tick do
        body = AsyncStreamingBody.new

        f = Fiber.new do
          env["async.callback"].call [200, Fiber.yield, body]
        end

        connection = EventMachine::HttpRequest.new(url)

        request = connection.public_send(http_method, head: headers, redirects: 3)

        p [http_method,url]

        request.headers do |headers|
          headers = ::Rack::Utils::HeaderHash.new(headers)
          headers["Transfer-Encoding"] = "chunked"
          headers.delete("Content-Encoding")
          headers.delete("Content-Length")

          f.resume
          f.resume(headers)
        end

        request.stream do |data|
          f.resume(data)
        end

        request.callback do |data|
          f.resume(data.response)
          body.stop!
        end

        request.errback do |data|
          f.resume(data.response)
          body.stop!
        end
      end

      throw(:async)
    end
  end
end
