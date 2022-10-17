require "http"
require "log"
require "json"
require "colorize"
require "random/secure"
require "kilt"
require "redis"

require "./kemal/version"
require "./kemal/controller/**"
require "./kemal/dsl/**"
require "./kemal/exceptions/**"
require "./kemal/extensions/**"
require "./kemal/router/context"
require "./kemal/pipes/**"
require "./kemal/server/**"
require "./kemal/validators/**"
require "./kemal/websockets/**"
require "./kemal/environment"

module Kemal
  include Kemal::Environment
end
