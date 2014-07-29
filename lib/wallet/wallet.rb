module RubyWallet
  class Wallet
    include Mongoid::Document
    include Coind

    field :iso_code,                  type: String

    field :rpc_user,                  type: String
    field :rpc_password,              type: Mongoid::EncryptedString
    field :rpc_host,                  type: String
    field :rpc_port,                  type: Integer
    field :rpc_ssl,                   type: Boolean

    field :encrypted,                 type: Boolean
    field :wallet_password,           type: Mongoid::EncryptedString

    field :unconfirmed_balance,       type: BigDecimal
    field :confirmed_balance,         type: BigDecimal

    field :confirmations,             type: Integer

    field :transaction_fee,           type: BigDecimal

    field :transaction_checked_count, type: Integer

    embeds_many :accounts
    embeds_many :transactions
    embeds_many :transfers

    validates_uniqueness_of :iso_code

    def encrypt
      if client.encrypt(self.wallet_password)
        self.update(wallet_encrypted: true)
      end
    end

    def transfer(sender, recipient, amount, comment = nil)
      if amount > 0 and sender.confirmed_balance >= amount and self.confirmed_balance >= amount and self.accounts.find_by(recipient.id).exists?
        # Subtract from the sender account
        self.create_transfer(sender_label:    sender.label,
                             sender_id:       sender.id,
                             recipient_label: recipient.label,
                             recipient_id:    recipeint.id,
                             category:        "send",
                             amount:          -amount,
                             comment:         comment
                            )
        # Add to the recipient account 
        self.create_transfer(sender_label:       sender.label,
                                sender_id:       sender.id,
                                recipient_label: recipient.label,
                                recipient_id:    recipeint.id,
                                category:        "receive",
                                amount:          amount,
                                comment:         comment
                               )
        # Update balances
      else
        false
      end
    end

    def withdraw(account, address, amount)
      if amount > self.transaction_fee and account.confirmed_balance >= amount and self.confirmed_balance >= amount and self.valid_address?(address)
        net_amount = amount - self.transaction_fee
        if net_amount > 0
          # transfer transaction fee to fee account so it is substracted from their total
          # send exccess fees to "" like null account
          client.sendtoaddress address, amount
        else
          false
        end
      else
        false
      end
    end

    def create_account(label)
      self.accounts.create(label: label)
    end

    def create_address(label)
      client.getnewaddress label
    end

    def own_address?(address)
      if response["ismine"]
        response["ismine"]
      else
        response["error"]
      end
    end

    def valid_address?(address)
      response = validate_address(address)
      if response["isvalid"]
        response["isvalid"]
      else
        response["error"]
      end
    end

    def sync
      client.listtransactions(nil, to, from)
      # refer to notes for implementation
    end

    def sync_transaction(transaction_id)
      client.get_transaction transaction_id
      # refer to notes for implementation
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
  
      def validate_address(address)
        client.validateaddress(address)
      end

      def update_balance
        self.update_attributes(balance: client.balance(nil, 0))
      end

      def transaction(transaction)
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

  end
end
