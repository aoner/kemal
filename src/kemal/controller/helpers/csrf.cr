module Kemal::Controller::Helpers
  module CSRF
    def csrf_token
      Kemal::Pipe::CSRF.token(context).to_s
    end

    def csrf_tag
      Kemal::Pipe::CSRF.tag(context)
    end

    def csrf_metatag
      Kemal::Pipe::CSRF.metatag(context)
    end
  end
end