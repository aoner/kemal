require "./environment/**"

module Kemal::Environment
  alias EnvType = String | Symbol

  macro included
    class_property path : String = "./config/environments/"
    @@settings : Settings?

    def self.settings
      @@settings ||= Loader.new(env.to_s, path).settings
    rescue Kemal::Exceptions::Environment
      @@settings = Settings.from_yaml("default: settings")
    end

    def self.env=(env : EnvType)
      @@env = Env.new(env.to_s)
      @@settings = Loader.new(env, path).settings
    end

    def self.env
      @@env ||= Env.new
    end
  end
end
