require "socket"
require_relative "http_status"
require_relative "request"
require_relative "router/router"

class HTTPServer
  attr_reader :host, :port, :router

  def initialize(port:, host: "localhost")
    puts "Listening to http://#{host}:#{port}"

    @host = host
    @port = port
    @server = TCPServer.new(host, port)
    @router = Router::Router.new
    configure_router
  end

  def start
    loop do
      Thread.start(@server.accept) do |session|
        handle_session(session)
      end
    end
  end

  private

  def handle_session(session)
    request = Request.new(session)
    status, _, response = @router.respond!(request)

    session.print("HTTP/1.1 #{status}\r\n")
    session.print("Content-Type: text/plain\r\n")
    session.print("Content-Length: #{response.size || 0}\r\n")
    session.print("\r\n")
    session.print(response)
  rescue IOError, Errno::EPIPE => e
    puts e.message
  ensure
    session.close
  end

  def configure_router
    @router.add_route("GET", "/") do |_req|
      [HTTPStatus::OK, {}, ""]
    end
    @router.add_route("GET", %r{/echo/(.*)}) do |req|
      msg = req.path.match(%r{/echo/(.*)})[1]
      [HTTPStatus::OK, {}, msg]
    end
    @router.add_route("GET", "/user-agent") do |req|
      msg = req.headers[2].split(": ")[1].strip
      [HTTPStatus::OK, {}, msg]
    end
    @router.set_fallback do
      [HTTPStatus::NotFound, {}, "Not Found"]
    end
  end
end

server = HTTPServer.new(port: 4221, host: "localhost")
server.start
