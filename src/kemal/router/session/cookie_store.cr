module Kemal::Router::Session
  class SessionHash
    property changed = false

    @store : Hash(String, String)
    forward_missing_to @store

    def initialize(pull : JSON::PullParser)
      @store = Hash(String, String).new(pull)
    end

    def initialize
      @store = {} of String => String
    end

    def []=(key : String | Symbol, value)
      if @changed |= (value != @store.fetch(key.to_s, nil))
        if value.nil?
          @store.delete(key)
        else
          @store[key.to_s] = value.to_s
        end
      end
    end

    def []?(key : Symbol)
      @store[key.to_s]?
    end

    def [](key)
      @store.fetch(key.to_s, nil)
    end

    def delete(key)
      @changed = true
      @store.delete(key.to_s)
    end
  end

  # This is the default Cookie Store
  class CookieStore < AbstractStore
    property key : String
    property expires : Int32
    property store : Kemal::Router::Cookies::SignedStore | Kemal::Router::Cookies::EncryptedStore
    property session : SessionHash

    forward_missing_to session

    def self.build(store, settings)
      new(store, settings[:key].to_s, settings[:expires].to_i)
    end

    def initialize(@store, @key, @expires)
      @session = current_session
    end

    def id
      session["id"] ||= UUID.random.to_s
    end

    def changed?
      session.changed
    end

    def destroy
      session.clear
    end

    def update(other_hash : Hash(String | Symbol, String))
      other_hash.each { |key, value| session[key.to_s] = value }
      session
    end

    def set_session
      store.set(key, session.to_json, expires: expires_at, http_only: true)
    end

    def expires_at
      Time.utc + expires.seconds if @expires > 0
    end

    def current_session
      SessionHash.from_json(store[key] || "{}")
    rescue e : JSON::ParseException
      SessionHash.new
    end
  end
end