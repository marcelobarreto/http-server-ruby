class Request
  def initialize(socket)
    @socket = socket
    @headers = set_headers(@socket.dup)
  end

  attr_reader :headers

  def method
    headers[0].split[0]
  end

  def path
    headers[0].split[1]
  end

  private

  def set_headers(socket)
    headers = []
    while (line = socket.gets) && line.chomp != ''
      headers << line
    end
    headers
  end
end
