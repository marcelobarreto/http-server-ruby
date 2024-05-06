require "socket"

require_relative "app"
require_relative "http_status"
require_relative "request"

class HTTPServer
  def initialize(port:, host: "localhost")
    puts "Listening to http://#{host}:#{port}"

    @host = host
    @port = port
    @server = TCPServer.new(host, port)
    @socket, @addr = @server.accept
    @request = Request.new(@socket)
  end

  def status(status)
    socket.write("HTTP/1.1 #{status}")
  end

  def write(s)
    socket.write("\r\n")
  end

  # private

  attr_reader :host, :port, :server, :socket, :addr, :request
end

http = HTTPServer.new(port: 4221)
puts http.request.headers
http.status(http.request.path.eql?("/") ? HTTPStatus::OK : HTTPStatus::NotFound)
http.write("\r\n")
http.write("\r\n")
