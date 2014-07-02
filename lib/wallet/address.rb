module RubyWallet
  class Address

    attr_reader :account, :address

    def initialize(account, address=nil)
      @account = account
      @address = if address
                   address
                 else
                   account.wallet.getnewaddress(account.name)
                 end
    end

    def total_received
      @account.wallet.getreceivedbyaddress(@address, RubyWallet.config.min_conf)
    end

    def private_key
      @account.wallet.private_key(@address)
    end

    def ==(other_address)
      @address == other_address.address
    end

  end
end
