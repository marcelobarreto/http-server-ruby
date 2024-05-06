require "socket"

require_relative "app"
require_relative "http_status"
require_relative "request"
require_relative "router/router"

router = Router::Router.new
router.add_route("GET", "/") do |req|
  [HTTPStatus::OK, {}, "Hello, World!"]
end
router.add_route("GET", /\/echo\/(.*)/) do |req|
  msg = req.path.match(/\/echo\/(.*)/)[1]
  [HTTPStatus::OK, {}, msg]
end
router.add_route("GET", "/user-agent") do |req|
  msg = req.headers[2].split(": ")[1].strip
  [HTTPStatus::OK, {}, msg]
end
router.set_fallback  do |req|
  [HTTPStatus::NotFound, {}, "Not found"]
end

class HTTPServer
  attr_reader :request, :host, :port, :routes

  class << self
    def listen(port:, router:, host: "localhost")
      server = new(port: 4221)
      server.set_router(router)

      loop do
        Thread.start(server.accept) do |session|
          server.respond!
        end
      end
    end
  end

  def initialize(port:, host: "localhost")
    puts "Listening to http://#{host}:#{port}"

    @host = host
    @port = port
    @server = TCPServer.new(host, port)
    @request = nil
    @socket = nil
    @addr = nil
    @router = nil
  end

  def set_router(router)
    @router = router
  end

  def accept
    @socket, @addr = @server.accept
    @request = Request.new(socket)
  end

  def respond!
    status, _, response = @router.respond!(request)

    write!("HTTP/1.1 #{status}")

    write!("Content-Type: text/plain")
    write!("Content-Length: #{response.size || 0}")
    write!("")
    write!(response)

    socket.close
  end

  private

  def write!(msg)
    socket.write(msg + "\r\n")
  end

  attr_reader :server, :socket, :addr
end

HTTPServer.listen(port: 4221, host: "localhost", router: router)
