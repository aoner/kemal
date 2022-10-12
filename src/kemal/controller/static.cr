require "./base"

module Kemal::Controller
  class Static < Base
    # If static resource is not found then raise an exception
    def index
      raise Kemal::Exceptions::RouteNotFound.new(request)
    end
  end
end