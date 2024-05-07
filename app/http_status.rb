class HTTPStatus
  class OK
    STATUS = 200
    def self.to_s
      "200 OK"
    end
  end

  class Created
    STATUS = 201
    def self.to_s
      "201 Created"
    end
  end

  class NotFound
    STATUS = 404
    def self.to_s
      "404 Not Found"
    end
  end
end
