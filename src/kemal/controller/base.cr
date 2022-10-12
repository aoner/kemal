require "http"

require "./filters"
require "./helpers/*"

module Kemal::Controller
  class Base
    include Helpers::CSRF
    include Helpers::Redirect
    include Helpers::Render
    include Helpers::Responders
    include Helpers::Route
    include Helpers::I18n
    include Callbacks

    protected getter context : HTTP::Server::Context
    protected getter params : Kemal::Validators::Params

    delegate :client_ip,
      :cookies,
      :delete?,
      :flash,
      :format,
      :get?,
      :halt!,
      :head?,
      :patch?,
      :port,
      :post?,
      :put?,
      :request,
      :requested_url,
      :response,
      :route,
      :session,
      :valve,
      :websocket?,
      to: context

    def initialize(@context : HTTP::Server::Context)
      @params = Kemal::Validators::Params.new(context.params)
    end
  end
end