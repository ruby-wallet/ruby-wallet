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
      @addresses ||= wallet.getaddressesbyaccount(name)
    end

    def balance(min_conf = 0)
      wallet.getbalance(self.name, min_conf)
    end

    def send_amount(amount, options={})
      if options[:to]
        options[:to] = options[:to].address if options[:to].is_a?(Address)
      else
        fail ArgumentError, 'address must be specified'
      end
      client.sendfrom(self.name,
                      options[:to],
                      amount,
                      RubyWallet.config.min_conf)
      rescue RestClient::InternalServerError => e
        parse_error e.response
    end

    def send_many(account_values={})
      addresses_values = {}
      account_values.each do |key, value|
        address = key.respond_to?(:address) ? key.address : key
        addresses_values[address] = value
      end

      txid = client.send_many(self.name,
                              addresses_values,
                              RubyWallet.config.min_conf)
      txid
    rescue => e
      error_message = JSON.parse(e.response).with_indifferent_access
      if error_message[:error][:code] == -6
        fail InsufficientFunds, "'#{self.name}' does not have enough funds"
      else
        raise e
      end
    end

    def move_to(amount, options={})
      to_account = wallet.accounts.where_account_name(options[:to])
      if to_account
        to = to_account.name
      else
        fail ArgumentError, "could not find account"
      end
      wallet.move(self.name, to, amount, RubyWallet.config.min_conf)
    end

    def total_received
      wallet.getreceivedbyaccount(self.name, RubyWallet.config.min_conf)
    end

    def ==(other_account)
      self.name == other_account.name
    end

    def transactions(from = 0, to)
      wallet.listtransactions(self.name, to, from).map do |hash|
        Transaction.new(self.wallet, hash)
      end
    end

    private

      def parse_error(response)
        json_response = JSON.parse(response)
        hash = json_response.with_indifferent_access
        error = if hash[:error]
                  case hash[:error][:code]
                  when -6
                    InsufficientFunds.new("cannot send an amount more than what this account (#{self.name}) has")
                  end
                end
        fail error if error
      end
  end
end
