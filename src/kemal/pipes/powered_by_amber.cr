module Kemal
  module Pipe
    class PoweredByAmber < Base
      def call(context : HTTP::Server::Context)
        context.response.headers["X-Powered-By"] = "Kemal"
        call_next(context)
      end
    end
  end
end