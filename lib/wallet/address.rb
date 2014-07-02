module RubyWallet
  class Address

    attr_reader :account, :address

    def initialize(account, address=nil)
      @address = if address
                   address
                 else
                   account.wallet.getnewaddress(account.name)
                 end
    end

    def total_received
      account.wallet.getreceivedbyaddress(self.address, RubyWallet.config.min_conf)
    end

    def private_key
      account.wallet.private_key(self.address)
    end

    def ==(other_address)
      self.address == other_address.address
    end

  end
end
