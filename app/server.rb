require "socket"

require_relative "app"

class HTTPServer
  def initialize(port:, host: "localhost")
    @host = host
    @port = port
    @server = TCPServer.new(host, port)
    @socket, @addr = @server.accept
  end

  def write(header:)
    # socket.write(response.join("\r\n") + "\r\n")
    socket.write("HTTP/1.1 200 OK\r\n\r\n")
  end

  private

  attr_reader :host, :port, :server, :socket, :addr
end

http = HTTPServer.new(port: 4221)
http.write(header: "HTTP/1.1 200 OK")
