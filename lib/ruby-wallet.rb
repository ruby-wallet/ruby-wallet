module Coind
  require 'coind/client'
  require 'coind/api'
  require 'coind/request'
  require 'coind/rpc'
  require 'coind/dsl'
  
  def Coind(user, pass, options = {})
    ::Coind::Client.new(user, pass, options)
  end
end

module RubyWallet
  require 'mongoid'

  Mongoid.load!(File.expand_path("../../mongoid.yml", __FILE__), :production)

  require 'wallet/wallet'
  require 'wallet/account'
  require 'wallet/transaction'
  require 'wallet/transfer'

  def self.connect(ruby_wallet)
    wallet = Wallet.find_by(rpc_user: ruby_wallet[:rpc_user])
    if wallet
      wallet
    else
      Wallet.create(rpc_user:     ruby_wallet[:rpc_user],
                    rpc_password: ruby_wallet[:rpc_password],
                    rpc_host:     ruby_wallet[:rpc_host],
                    rpc_port:     ruby_wallet[:rpc_port],
                    rpc_ssl:      ruby_wallet[:rpc_ssl])
    end
  end
end
