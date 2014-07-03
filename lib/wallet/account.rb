module RubyWallet
  class Account

    attr_reader :wallet, :name

    def initialize(wallet, name)
      @wallet = wallet
      @name = name
    end

    def generate_new_address
      Address.new(self)
    end

    def addresses
      @addresses ||= @wallet.addresses_by_account(name)
    end

    def balance(min_conf = 0)
      @wallet.balance(@name, min_conf)
    end

    def send_amount(amount, recipient)
      # Could do a regex check here
      unless recipient
        fail ArgumentError, 'address must be specified'
      end
      @wallet.send_from_to(@name, recipient, amount)
    end

    def send_from_to_many(account={})
      addresses = {}
      accounts.each do |key, value|
        address = key.respond_to?(:address) ? key.address : key
        addresses[address] = value
      end

      @wallet.send_many(@name, addresses_values)
    end

    def move_to(amount, to)
      recipient_account = @wallet.accounts.where_account_name(to)
      if recipient_account
        recipient = to_account.name
      else
        fail ArgumentError, "could not find account"
      end
      @wallet.transfer(@name, recipient, amount)
    end

    def total_received
      @wallet.received_by_account(@name)
    end

    def ==(other_account)
      @name == other_account.name
    end

    def transactions(from = 0, to)
      @wallet.transactions(@name, to, from)
    end
  end
end
