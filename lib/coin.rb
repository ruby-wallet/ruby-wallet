module Coin
  autoload :Client, 'coin/client'
  autoload :API,    'coin/api'
  autoload :Request,'coin/request'
  autoload :RPC,    'coin/rpc'
  autoload :Errors, 'coin/errors'
  autoload :Version,'coin/version'
  autoload :VERSION,'coin/version'
  autoload :DSL,    'coin/dsl'
  
  def self.included(base)
    base.send(:include, Coin::DSL)
    base.send(:extend,  Coin::DSL)
  end
end

def Coin(user, pass, options = {})
  ::Coin::Client.new(user, pass, options)
end

require 'ostruct'
require 'active_support/core_ext/module/attribute_accessors'
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
