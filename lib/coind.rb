module Coind
  require 'coind/client'
  require 'coind/api'
  require 'coind/request'
  require 'coind/rpc'
  require 'coind/errors'
  require 'coind/version'
  require 'coind/version'
  require 'coind/dsl'
  
  def self.included(base)
    base.send(:include, Coin::DSL)
    base.send(:extend,  Coin::DSL)
  end

  def Coind(user, pass, options = {})
    ::Coind::Client.new(user, pass, options)
  end
end


module RubyWallet
  require 'mongoid'
  Mongoid.load!('../mongoid.yml', :production)

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


  mattr_accessor :config
  @@config = OpenStruct.new

  def self.connect(*args)
    Wallet.new(*args)
  end

  def self.initialize(*args)
    Wallet.new(*args)
  end
end
