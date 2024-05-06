class HTTPStatus
  class OK
    STATUS = 200
    def self.to_s
      "200 OK"
    end
  end

  class NotFound
    STATUS = 404
    def self.to_s
      "404 Not Found"
    end
  end
end
