module RubyWallet
  class Wallet
    include Mongoid::Document
    #include Mongoid::Paranoia

    include Coind

    field :iso_code,                  type: String

    field :rpc_user,                  type: String
    field :rpc_password,              type: Mongoid::EncryptedString
    field :rpc_host,                  type: String
    field :rpc_port,                  type: Integer
    field :rpc_ssl,                   type: Boolean

    field :encrypted,                 type: Boolean
    field :wallet_password,           type: Mongoid::EncryptedString

    field :unconfirmed_balance,       type: BigDecimal,                default: 0
    field :confirmed_balance,         type: BigDecimal,                default: 0

    field :confirmations,             type: Integer

    field :transaction_checked_count, type: Integer,                   default: 0

    field :last_updated,              type: Time,                      default: Time.now

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
        self.create_transfer(sender_label:    sender.label,
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
      if account.confirmed_balance >= amount and self.confirmed_balance >= amount and self.valid_address?(address)
        # Transaction fees should be handled higher in the stack
        client.sendtoaddress address, amount
      else
        false
      end
    end

    def create_account(label)
      self.accounts.create(label: label)
    end

    def generate_address(label)
      client.getnewaddress label
    end

    def own_address?(address)
      response = validate_address(address)
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
      wallet_transactions = client.listtransactions(nil, 99999)
      reset_transactions if self.transaction_checked_count > wallet_transactions.count
      if wallet_transactions and self.transaction_checked_count != wallet_transactions.count
        wallet_transactions[self.transaction_checked_count..wallet_transactions.count].each do |txn|
          self.update_attributes(transaction_checked_count: self.transaction_checked_count + 1)
          self.transactions.create(account_label: transaction["account"],
                                   transaction_id: transaction["txid"],
                                   address: transaction["address"],
                                   amount: BigDecimal.new(transaction["amount"]),
                                   confirmations: transaction["confirmations"].to_i,
                                   occurred_at: Time.at(transaction["time"]),
                                   received_at: Time.at(transaction["timereceived"]),
                                   category: transaction["category"]
                                  )
          self.update_total_received_by_label(transaction["account"]) if transaction["category"] == "receive"
        end
      end
      self.transactions.where(confirmed => false).each do |transaction|
        wallet_transaction = self.api.get_transaction(transaction.transaction_id)
        unless wallet_transaction.class == "Hash" # This indicates it returned an error
          transaction.update_attributes(confirmations: wallet_transaction.confirmations)
          if transaction.confirmations >= self.confirmations
            transaction.confirm
          end
        end
      end
      self.update_balances
      self.update_attributes(last_update: Time.now)
    end 

    def sync_transaction(transaction_id)
      transaction = self.transactions.find_by(transaction_id)
      if transaction
        wallet_transaction = client.get_transaction(transaction_id)
        unless wallet_transaction.class == "Hash" # This indicates it returned an error
          if transaction.status == "pending"
            transaction.update_attributes(confirmations: wallet_transaction.confirmations)
            if transaction.confirmations >= self.confirmations
              transaction.confirm
            end
          end
        end
      else
        sync
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
  
      def validate_address(address)
        client.validateaddress(address)
      end

      def update_balances
        self.update_attributes(unconfirmed_balance: client.balance(nil, 0),
                               confirmed_balance:   client.balance(nil, self.confirmations)
                              )
      end

      def reset_transactions
        self.transactions.destroy
        self.update_attributes(transction_checked_count: 0)
      end

      def update_total_received_by_label(label)
        account = self.accounts.find_by(label: label)
        account.update_attributes(total_received: client.getreceivedbylabel(label))
      end

  end
end
