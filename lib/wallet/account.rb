module RubyWallet
  class Account
    include Mongoid::Document

    field :label,                type: String
    field :addresses,            type: Array,         default: []

    field :total_received,       type: BigDecimal,    default: 0

    embedded_in :wallet

    after_create :new_address

    def new_address
      address = self.wallet.new_address(self.label)
      self.update_attributes(addresses: self.addresses.push(address))
    end

    def transfers
      transfers.any_of({sender_label: self.label}, {recipient_label: self.label})
    end

    def transactions
      self.wallet.transactions.where(label: self.label)
    end

    def deposits
      transactions.where(category: "deposit")
    end

    def withdrawals
      transactions.where(category: "withdrawal")
    end

    def balance(minimum_confirmations)
      balance = BigDecimal(0)
      balance += self.deposits.where(confirmations: minimum_confirmations).reduce(0){|sum, deposit| sum + deposit.amount}
      balance += self.withdrawals.reduce(0){|sum, withdrawal| sum + withdrawal.amount}
      balance += self.transfers.reduce(0){|sum, transfer| sum + transfer.amount}
      balance
    end

    def withdraw(amount, address)
      # 1. Confirm amount
      # 2. Confirm address is legit
      # 3. Send money
    end

    def transfer(amount, recipient, comment = nil)
      # 1. Confirm amount
      # 2. Confirm recipient exists
      # 3. Send money within internal database and create two transfers (double book keeping, -x amount from sender account +x amount to recipient account)
      # 4. Comment with trade_id for better record keeping
    end

    protected

      def update_total_received
        self.update_attributes(total_received: self.wallet.total_received(self.label))
      end

  end
end
