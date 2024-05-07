require "pry"
require "socket"
require_relative "http_status"
require_relative "request"
require_relative "router/router"

class HTTPServer
  attr_reader :host, :port, :router, :static_directory

  def initialize(port:, host: "localhost", static_path: "static")
    puts "Listening to http://#{host}:#{port}"

    @host = host
    @port = port
    @server = TCPServer.new(host, port)
    @router = Router::Router.new
    @static_directory = File.join(static_path)

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

  def handle_session(session, &block)
    request = Request.new(session)
    status, headers, response = @router.respond!(request)

    session.print("HTTP/1.1 #{status}\r\n")
    headers.each do |key, value|
      session.print("#{key}: #{value}\r\n")
    end
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
    @router.add_route("GET", /\/echo\/(.*)/) do |req|
      msg = req.path.match(/\/echo\/(.*)/)[1]
      headers = {"Content-Type" => "text/plain", "Content-Length" => msg.size}
      [HTTPStatus::OK, headers, msg]
    end
    @router.add_route("GET", /\/files\/(.*)/) do |req|
      filepath = File.join(static_directory, req.path.match(/\/files\/(.*)/)[1])
      if File.exists?(filepath)
        file = File.read(filepath)
        puts file
        headers = {"Content-Type" => "application/octet-stream", "Content-Length" => file.size}
        [HTTPStatus::OK, headers, file]
      else
        message = "Not Found"
        [HTTPStatus::NotFound, { "Content-Type" => "text/plain", "Content-Length" => message.size}, message]
      end
    end
    @router.add_route("GET", "/user-agent") do |req|
      msg = req.headers[2].split(": ")[1].strip
      headers = {"Content-Type" => "text/plain", "Content-Length" => msg.size}
      [HTTPStatus::OK, headers, msg]
    end
    @router.set_fallback do
      message = "Not Found"
      [HTTPStatus::NotFound, { "Content-Type" => "text/plain", "Content-Length" => message.size}, message]
    end
  end
end

server = HTTPServer.new(port: 4221, host: "localhost", static_path: ARGV[1] || "static")
server.start
