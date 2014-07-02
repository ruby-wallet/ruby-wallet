module RubyWallet
  class Address

    attr_reader :account, :address

    def initialize(account, address=nil)
      @account = account
      @address = if address
                   address
                 else
                   client.getnewaddress(account.name)
                 end
    end

    def total_received
      client.getreceivedbyaddress(@address, RubyWallet.config.min_conf)
    end

    def private_key
      client.private_key(@address)
    end

    def ==(other_address)
      @address == other_address.address
    end

  end
end
