require "socket"

require_relative "app"
require_relative "http_status"
require_relative "request"
require_relative "router/router"

class HTTPServer
  attr_reader :request, :host, :port, :routes

  def initialize(port:, host: "localhost")
    puts "Listening to http://#{host}:#{port}"

    @host = host
    @port = port
    @server = TCPServer.new(host, port)
    @socket, @addr = @server.accept
    @request = Request.new(@socket)
    @router = nil
  end

  def set_router(router)
    @router = router
  end

  def respond!
    status, _, response = @router.respond!(request)
    write!("HTTP/1.1 #{status}")
    write!("Content-Type: text/plain")
    write!("Content-Length: #{response.size}")
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

http = HTTPServer.new(port: 4221)
router = Router::Router.new
router.add_route("GET", "/") { [HTTPStatus::OK, {}, Proc.new { |req| "Hello, World!" }] }
router.add_route("GET", /\/echo\/(.*)/) do |req|
  msg = req.path.match(/\/echo\/(.*)/)[1]
  [HTTPStatus::OK, {}, msg]
end
router.set_fallback { [HTTPStatus::NotFound, {}, Proc.new { |req| "Not found" }] }

http.set_router(router)

http.respond!

# http.status(HTTPStatus::OK)
# http._socket.write("\r\n")
# http._socket.write("\r\n")
