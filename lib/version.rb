module RubyWallet
  module Version
    MAJOR = 0
    MINOR = 3
    PATCH = 0
    REL = nil
    STRING = REL ? [MAJOR, MINOR, PATCH, REL].join('.') : [MAJOR, MINOR, PATCH].join('.')
  end
  VERSION = Version::STRING
end
