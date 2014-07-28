module Coind
  require 'coind/client'
  require 'coind/api'
  require 'coind/request'
  require 'coind/rpc'
  
  def Coind(options)
    Coind::Client.new(options)
  end
end

module Coin
  def self.config(iso_code, env)
    @config[iso_code.to_sym][env.to_sym].symbolize_keys
  end

  def self.set(hash)
    @config = hash
  end
end

module RubyWallet
  config = YAML::load_file(File.expand_path('../../config/config.yml', __FILE__))

  require 'mongoid'
  require 'mongoid/encrypted_string/global'

  Mongoid.load!(File.expand_path("../../config/mongoid.yml", __FILE__), config['ENV'].to_sym)
  Mongoid::EncryptedString.config.key = config['ENCRYPTION_KEY']

  Coin.set(YAML.load_file("../../config/coins.yml").symbolize_keys)

  require 'wallet/wallet'
  require 'wallet/account'
  require 'wallet/transaction'
  require 'wallet/transfer'

  def self.connect(iso_code)
    wallet = Wallet.find_by(iso_code: iso_code)
    if wallet
      wallet
    else
      Wallet.create(rpc_user:     Coin.config(iso_code, config['ENV'].to_sym)[:rpc_user],
                    rpc_password: Coin.config(iso_code, config['ENV'].to_sym)[:rpc_password],
                    rpc_host:     Coin.config(iso_code, config['ENV'].to_sym)[:rpc_host],
                    rpc_port:     Coin.config(iso_code, config['ENV'].to_sym)[:rpc_port],
                    rpc_ssl:      Coin.config(iso_code, config['ENV'].to_sym)[:rpc_ssl])
    end
  end
end
