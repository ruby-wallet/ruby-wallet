module Bitcoin
  autoload :Client, 'bitcoin/client'
  autoload :API,    'bitcoin/api'
  autoload :Request,'bitcoin/request'
  autoload :RPC,    'bitcoin/rpc'
  autoload :Errors, 'bitcoin/errors'
  autoload :Version,'bitcoin/version'
  autoload :VERSION,'bitcoin/version'
  autoload :DSL,    'bitcoin/dsl'
  
  def self.included(base)
    base.send(:include, Bitcoin::DSL)
    base.send(:extend,  Bitcoin::DSL)
  end
end

def Bitcoin(user, pass, options = {})
  ::Bitcoin::Client.new(user, pass, options)
end

require 'ostruct'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string'

require 'wallet/wallet'
require 'wallet/account'
require 'wallet/accounts'
require 'wallet/address'
require 'wallet/transaction'
require 'wallet/errors'

module RubyWallet
  mattr_accessor :config
  @@config = OpenStruct.new

  def self.connect(*args)
    Wallet.new(*args)
  end

  def self.initialize(*args)
    Wallet.new(*args)
  end
end
