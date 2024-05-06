module Router
  class Route
    attr_reader :path, :http_method

    def initialize(http_method, path, &block)
      @http_method = http_method
      @path = path
      @block = block
    end

    def response(request)
      @response ||= @block.call(request)
    end
  end
end
