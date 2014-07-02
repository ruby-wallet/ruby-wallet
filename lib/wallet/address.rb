module RubyWallet
  class Address

    attr_reader :account, :address

    def initialize(account, address=nil)
      @account = account
      @address = if address
                   address
                 else
                   @account.wallet.new_address(account.name)
                 end
    end

    def total_received
      @account.wallet.received_by_address(@address)
    end

    def ==(other_address)
      @address == other_address.address
    end

  end
end
