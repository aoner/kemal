require "./*"
require "../support/locale_formats"

# We are patching the String class and Number struct to extend the predicates
# available. This will allow to add friendlier methods for validation cases.
class String
  include Kemal::Extensions::String
end

abstract struct Number
  include Kemal::Extensions::Number
end

class HTTP::Server::Context
  include Kemal::Extensions::HTTPServerContext
end