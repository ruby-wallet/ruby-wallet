module Coind
  module Version
    MAJOR = 0
    MINOR = 2
    PATCH = 2
    REL = nil
    STRING = REL ? [MAJOR, MINOR, PATCH, REL].join('.') : [MAJOR, MINOR, PATCH].join('.')
  end
  VERSION = Version::STRING
end
