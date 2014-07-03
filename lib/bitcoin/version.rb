module Coin
  module Version
    MAJOR = 0
    MINOR = 1
    PATCH = 1
    REL = nil
    STRING = REL ? [MAJOR, MINOR, PATCH, REL].join('.') : [MAJOR, MINOR, PATCH].join('.')
  end
  VERSION = Version::STRING
end
