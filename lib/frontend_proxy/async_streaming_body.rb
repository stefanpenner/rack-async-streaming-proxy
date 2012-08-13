module FrontendProxy
  class AsyncStreamingBody
    EOL = "\r\n"
    attr_reader :run

    def initialize
      @run = true
    end

    def stop!
      @run = false
    end

    def each(&blk)
      while run do
        yield FrontendProxy::Util.chunk(Fiber.yield)
      end
    end
  end
end
