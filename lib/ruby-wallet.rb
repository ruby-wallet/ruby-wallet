module Coind
  require 'coind/client'
  require 'coind/api'
  require 'coind/request'
  require 'coind/rpc'
  
  def Coind(options)
    Coind::Client.new(options)
  end
end

module RubyWallet
  require 'mongoid'
  require 'mongoid/encrypted_string/global'
  config = YAML::load_file(File.expand_path('../../config/config.yml', __FILE__))
  Mongoid.load!(File.expand_path("../../config/mongoid.yml", __FILE__), :production)
  Mongoid::EncryptedString.config.key = config['ENCRYPTION_KEY']

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
