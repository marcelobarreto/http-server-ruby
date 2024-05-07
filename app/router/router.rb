require_relative "route"

module Router

  class Router
    class RouteNotFound < StandardError; end
    class RouteAlreadyDefined < StandardError; end
    class FallbackRouteNotDefined < StandardError; end

    def initialize
      @routes = {
        "GET" => {},
        "POST" => {},
        "PUT" => {},
        "PATCH" => {},
        "DELETE" => {},
        "OPTIONS" => {},
      }
    end

    def find(method, path)
      return routes[method].each do |route_path, route|
        return route if route_path.match(path)
      end
    end

    def respond!(request)
      route = find(request.http_method, request.path)
      raise RouteNotFound, "Route not found" if route.nil?
      puts "Incoming request: #{request.http_method} #{request.path}"
      route.response(request)
    rescue => e
      if defined?(@fallback)
        @fallback.call(request)
      else
        raise FallbackRouteNotDefined, "Route not found"
      end
    end

    def add_route(method, path, &block)
      method = method.to_s.upcase
      raise RouteAlreadyDefined, "Route already defined" if route_defined?(method, path)
      routes[method][path] = Route.new(method, path, &block)
    end

    def route_defined?(method, path)
      !!routes.dig(method, path)
    end

    def set_fallback(&block)
      @fallback = block
    end

    def [](key)
      routes[key]
    end

    private

    attr_reader :routes
  end
end
