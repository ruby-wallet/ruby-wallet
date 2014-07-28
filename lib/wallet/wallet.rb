module RubyWallet
  class Wallet
    include Mongoid::Document
    include Coind

    field :iso_code,               type: String

    field :rpc_user,               type: String
    field :rpc_password,           type: Mongoid::EncryptedString
    field :rpc_host,               type: String
    field :rpc_port,               type: Integer
    field :rpc_ssl,                type: Boolean

    field :wallet_password,        type: Mongoid::EncryptedString

    field :total_balance,          type: BigDecimal

    field :transfer_count,         type: Integer
    field :transaction_count,      type: Integer

    embeds_many :accounts
    embeds_many :transactions
    embeds_many :transfers

    validates_uniqueness_of :iso_code


    def create_transaction(transaction)
      self.create_transaction(account_label: transaction["account"],
                              transaction_id: transaction["txid"],
                              address: transaction["address"],
                              recipient_account: transaction["otheraccount"],
                              amount: BigDecimal.new(transaction["amount"]),
                              confirmations: transaction["confirmations"].to_i,
                              occurred_at: Time.at(transaction["time"]),
                              received_at: Time.at(transaction["timereceived"]),
                              category: transaction["category"]
                             )
    end


    
    def fetch_transaction(txid)
      Transaction.new(self, client.gettransaction(txid))
    end

    def new_address(account_label = nil)
      client.getnewaddress(account_label)
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
      if self.balance(from, min_conf) >= amount and self.balance >= amount
        client.move(from, to, amount, min_conf)
      else
        return false
      end
    end
    
    def total_balance(min_confirmations = 0)
      client.balance(nil, min_confirmations)
    end

    def populate_transactions(account = "*", from = 0, to)
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

    def own_address?(address)
      if response["ismine"]
        return response["ismine"]
      else
        return response["error"]
      end
    end

    def valid_address?(address)
      response = validate_address(address)
      if response["isvalid"]
        return response["isvalid"]
      else
        return response["error"]
      end
    end

    private

      def client
        @client ||= Coind({:rpc_user =>     self.rpc_user,
                           :rpc_password => self.rpc_password,
                           :rpc_host =>     self.rpc_host,
                           :rpc_port =>     self.rpc_port,
                           :rpc_ssl =>      self.rpc_ssl})
      end

      def validate_address(address)
        client.validateaddress(address)
      end

  end
end
