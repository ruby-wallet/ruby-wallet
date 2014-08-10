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

    field :rpc_online,                type: Boolean

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
    validates_uniqueness_of :rpc_user

    index({"transactions.transaction_id" => 1}, {unique: true, sparse: true})
    index({"accounts.label" => 1}, {unique: true, sparse: true})

    def coind_online?
      begin
        response = coind.getbalance
        if response["error"].nil?
          update_attributes(rpc_online: true)
          rpc_online
        else
          update_attributes(rpc_online: false)
          rpc_online
        end
      rescue
        update_attributes(rpc_online: false)
        rpc_online
      end
    end

    def encrypt
      if coind.encrypt(wallet_password)
        update_attributes(encrypted: true)
      end
    end

    def encrypted?
      encrypted
    end

    def update_balances
      if coind_online?
        update_attributes(unconfirmed_balance: coind.getbalance(0),
                          confirmed_balance:   coind.getbalance(confirmations)
                         )
      end
    end

    def account(label)
      accounts.find_by(label: label)
    end

    def transaction(transaction_id)
      transactions.find_by(transaction_id: transaction_id)
    end

    def transfer(sender, recipient, amount, comment = nil)
      if amount > BigDecimal.new(0) and sender.confirmed_balance >= amount and confirmed_balance >= amount and accounts.find(recipient.id).persisted? and accounts.find(sender.id).persisted?
        transfers.create(sender_label:    sender.label,
                         sender_id:       sender.id,
                         recipient_label: recipient.label,
                         recipient_id:    recipient.id,
                         category:        "send",
                         amount:          -amount,
                         comment:         comment
                        )
        transfers.create(sender_label:    sender.label,
                         sender_id:       sender.id,
                         recipient_label: recipient.label,
                         recipient_id:    recipient.id,
                         category:        "receive",
                         amount:          amount,
                         comment:         comment
                        )
        sender.update_balances
        recipient.update_balances
      else
        false
      end
    end

    def withdraw(account, address, amount)
      if account.confirmed_balance >= amount and confirmed_balance >= amount and valid_address?(address)
        unlock if encrypted?
        txid = coind.sendtoaddress(address, amount.to_f, account.label)
        p txid.to_s
        if txid['error'].nil?
          account.update_attributes(withdrawal_ids: account.withdrawal_ids.push(txid).uniq)
          account.update_balances
          sync
          txid
        else
          false
        end
      else
        false
      end
    end

    def create_account(label)
      unlock if encrypted?
      if account(label)
        account(label)
      else
        accounts.create!(label: label)
      end
    end

    def generate_address(label)
      unlock if encrypted?
      coind.getnewaddress(label)
    end

    def label(address)
      response = validate_address(address)
      if !response["account"].nil?
        response["account"]
      elsif !response["error"].nil?
        response["error"]
      else
        response
      end
    end

    def total_received(label)
      coind.getreceivedbylabel(label)
    end

    def own_address?(address)
      response = validate_address(address)
      if !response["ismine"].nil?
        response["ismine"]
      elsif !response["error"].nil?
        response["error"]
      else
        response
      end
    end

    def valid_address?(address)
      response = validate_address(address)
      if !response["isvalid"].nil?
        response["isvalid"]
      elsif !response["error"].nil?
        response["error"]
      else
        response
      end
    end

    def sync
      if coind_online?
        wallet_transactions = coind.listtransactions("*", 99999)
        reset_transactions if transaction_checked_count > wallet_transactions.length
        if wallet_transactions and transaction_checked_count != wallet_transactions.length and wallet_transactions[transaction_checked_count..wallet_transactions.length] > 0
          wallet_transactions[transaction_checked_count..wallet_transactions.length].each do |transaction|
            update_attributes(transaction_checked_count: transaction_checked_count + 1)
            if transaction["category"] == "receive"
              account = accounts.find_by(:addresses.in => [transaction["address"]])
            elsif transaction["category"] == "send"
              account = accounts.find_by(label: transaction["comment"])
            end
            if account
              new_transaction = transactions.create(account_label:  account.label,
                                                    transaction_id: transaction["txid"],
                                                    address:        transaction["address"],
                                                    amount:         BigDecimal.new(transaction["amount"].to_s),
                                                    confirmations:  transaction["confirmations"],
                                                    occurred_at:    (Time.at(transaction["time"].utc) if !transaction["time"].nil?),
                                                    received_at:    (Time.at(transaction["timereceived"].utc) if !transaction["timereceived"].nil?),
                                                    category:       transaction["category"],
                                                    comment:        transaction["comment"]
                                                   )
              if transaction["category"] == "receive"
                account.update_attributes(deposit_ids: account.deposit_ids.push(transaction["txid"]).uniq, total_received: total_received(account.label))
                if new_transaction.confirmations >= confirmations
                  new_transaction.confirm
                  account.update_confirmed_balance
                else
                  account.update_unconfirmed_balance
                end
              end
            end
          end
        end
        self.transactions.where(confirmed: false, category: "receive").each do |transaction|
          wallet_transaction = coind.get_transaction(transaction.transaction_id)
          transaction.update_attributes(confirmations: wallet_transaction['confirmations'])
          if transaction.confirmations >= confirmations
            transaction.confirm
            account.update_confirmed_balance
          end
        end
        update_balances
        update_attributes(last_update: Time.now)
      end
    end 

    def sync_transaction(transaction_id)
      transaction = transaction(transaction_id)
      if transaction
        wallet_transaction = coind.get_transaction(transaction_id)
        unless transaction.confirmed?
          transaction.update_attributes(confirmations: wallet_transaction['confirmations'])
          if transaction.confirmations >= confirmations
            transaction.confirm
          end
        end
      else
        sync
      end 
    end

    private

      def coind
        @client ||= Coind({:rpc_user =>    self.rpc_user,
                          :rpc_password => self.rpc_password,
                          :rpc_host =>     self.rpc_host,
                          :rpc_port =>     self.rpc_port,
                          :rpc_ssl =>      self.rpc_ssl})
      end

      def unlock(timeout = 20) #, &block)
        coind.unlock(self.wallet_password, timeout)
        #if block
        #  block.call
        #  coind.lock
        #end
      end
  
      def validate_address(address)
        coind.validateaddress(address)
      end

      def reset_transactions
        transactions.destroy
        update_attributes(transaction_checked_count: 0)
      end

  end
end
