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

    field :encrypted,              type: Boolean
    field :wallet_password,        type: Mongoid::EncryptedString

    field :balance,                type: BigDecimal

    field :transfer_count,         type: Integer
    field :transaction_count,      type: Integer

    embeds_many :accounts
    embeds_many :transactions
    embeds_many :transfers

    validates_uniqueness_of :iso_code

    def create_account(label)
      self.accounts.create(label: label)
    end

    def create_transaction(transaction)
      self.transactions.create(account_label: transaction["account"],
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

    def create_transfer(sender_label, recipient_label, amount, comment = nil)

    end

    def new_address(label)
      client.getnewaddress(label)
    end

    def populate_transactions(account = "*", from = 0, to)
      client.listtransactions(account, to, from).map do |hash|
        Transaction.new(self, hash)
      end
    end

    def encrypt
      if client.encrypt(self.wallet_password)
        self.update(wallet_encrypted: true)
      end
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
        @coind ||= Coind({:rpc_user =>     self.rpc_user,
                          :rpc_password => self.rpc_password,
                          :rpc_host =>     self.rpc_host,
                          :rpc_port =>     self.rpc_port,
                          :rpc_ssl =>      self.rpc_ssl})
      end

      def unlock(timeout = 20, &block)
        client.unlock(self.wallet_password, timeout)
        if block
          block.call
          client.lock
        end
      end
  
      def lock
        client.lock
      end

      def validate_address(address)
        client.validateaddress(address)
      end

      def get_transaction(transaction_id)
        client.gettransaction(transaction_id)
      end

      def update_balance
        self.update_attributes(balance: client.balance(nil, 0))
      end

  end
end
