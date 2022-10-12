require "yaml"
require "yaml_mapping"

module Kemal::Environment
  class Settings
    alias SettingValue = String | Int32 | Bool | Nil

    setter session : Hash(String, Int32 | String)
    property database_url : String,
      host : String,
      name : String,
      port : Int32,
      port_reuse : Bool,
      process_count : Int32,
      redis_url : String?,
      secret_key_base : String,
      secrets : Hash(String, String),
      ssl_key_file : String,
      ssl_cert_file : String,
      logging : Logging::OptionsType

    property? auto_reload : Bool

    YAML.mapping(
      logging: {
        type:    Logging::OptionsType,
        default: Logging::DEFAULTS,
      },
      database_url: {type: String, default: ""},
      host: {type: String, default: "localhost"},
      name: {type: String, default: "Kemal_App"},
      port: {type: Int32, default: 3000},
      port_reuse: {type: Bool, default: true},
      process_count: {type: Int32, default: 1},
      redis_url: {type: String?, default: nil},
      secret_key_base: {type: String, default: Random::Secure.urlsafe_base64(32)},
      secrets: {type: Hash(String, String), default: Hash(String, String).new},
      session: {type: Hash(String, Int32 | String), default: {
        "key" => "elixir.session", "store" => "signed_cookie", "expires" => 0,
      }},
      ssl_key_file: {type: String?, default: nil},
      ssl_cert_file: {type: String?, default: nil},
      auto_reload: {type: Bool, default: false},
      pipes: {
        type:    Hash(String, Hash(String, Hash(String, SettingValue))),
        default: {
          "static" => {
            "headers" => {} of String => SettingValue,
          },
        },
      }
    )

    def session
      {
        :key     => @session["key"].to_s,
        :store   => session_store,
        :expires => @session["expires"].to_i,
      }
    end

    def session_store
      case @session["store"].to_s
      when "signed_cookie" then :signed_cookie
      when "redis"         then :redis
      else                      "encrypted_cookie"
      :encrypted_cookie
      end
    end

    def logging
      @_logging ||= Logging.new(@logging)
    end
  end
end
