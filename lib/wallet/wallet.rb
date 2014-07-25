module RubyWallet
  class Wallet

    def initialize(config={})
      @config = config
    end
    
    def blockcount
      client.getblockcount
    end

    def get_transaction(txid)
      client.gettransaction(txid)
    end

    def new_address(account = nil)
      client.getnewaddress(account)
    end

    def addresses_by_account(name)
      client.getaddressesbyaccount(name)
    end

    def send_from_to(from, to, amount, min_conf = RubyWallet.config.min_conf)
      client.sendfrom(from, to, amount, min_conf)
      rescue RestClient::InternalServerError => e
        parse_error e.response
    end
 
    def send_from_to_many(from, addresses, min_conf = RubyWallet.config.min_conf)
      client.send_many(from, addresses, min_conf)
      rescue => e
        error_message = JSON.parse(e.response).with_indifferent_access
        if error_message[:error][:code] == -6
          fail InsufficientFunds, "'#{self.name}' does not have enough funds"
        else
          raise e
        end
    end
 
    def transfer(from, to, amount, min_conf = RubyWallet.config.min_conf)
      client.(from, to, amount, min_conf)
    end
    
    def received_by_account(account, min_conf = RubyWallet.config.min_conf)
      client.getreceivedbyaccount(account, min_conf)
    end
  
    def received_by_address(address, min_conf = RubyWallet.config.min_conf)  
      client.getreceivedbyaddress(address, min_conf)
    end
   
    def balance(account = nil, min_conf = 0)
      client.balance(account, min_conf)
    end

    def total_received(account = "*", min_conf = 0)
      client.getreceivedbyaccount(account, min_conf)
    end

    def list_accounts
      client.listaccounts
    end

    def accounts
      @accounts ||= Accounts.new(self)
    end

    def transactions(account = "*", from = 0, to)
      client.listtransactions(account, to, from).map do |hash|
        Transaction.new(self, hash)
      end
    end

    def encrypt(passphrase)
      client.encrypt(passphrase)
    end

    def unlock(passphrase, timeout = 20, &block)
      client.unlock(passphrase, timeout)
      if block
        block.call
        client.lock
      end
    end

    def lock
      client.lock
    end

    def validate_address(coinaddress)
      client.validateaddress(coinaddress)
    end

    private
      def client
        @client ||= Coind(@config[:username],
                          @config[:password],
                          :port => (@config[:port] || "8332"),
                          :host => (@config[:host] || "localhost"),
                          :ssl => (@config[:ssl] || false))
      end

      def parse_error(response)
        json_response = JSON.parse(response)
        hash = json_response.with_indifferent_access
        error = if hash[:error]
                  case hash[:error][:code]
                  when -6
                    InsufficientFunds.new("cannot send an amount more than what this account (#{@name}) has")
                  end
                end
        fail error if error
      end

  end
end
