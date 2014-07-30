module RubyWallet
  class Account
    include Mongoid::Document

    field :label,                type: String
    field :addresses,            type: Array,         default: []

    field :unconfirmed_balance,  type: BigDecimal,    default: 0
    field :confirmed_balance,    type: BigDecimal,    default: 0

    field :total_received,       type: BigDecimal,    default: 0

    embedded_in :wallet

    after_create :generate_address

    def generate_address
      address = self.wallet.generate_address(self.label)
      self.update_attributes(addresses: self.addresses.push(address))
    end

    def transfers
      transfers.any_of({sender_label: self.label, category: "send"}, {recipient_label: self.label, category: "receive"})
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

    def withdraw(address, amount)
      self.wallet.withdraw(self, address, amount)
      self.upadte_balances
    end

    def transfer(recipient_label, amount, comment = nil)
      recipient = self.wallet.accounts.find_by(label: recipient_label)
      if recipient
        self.wallet.transfer(self, recipient, amount, comment)
        self.update_balances
      else
        false
      end
    end

    def update_balances
      self.update_unconfirmed_balance
      self.update_confirmed_balance
    end

    protected

      def update_unconfirmed_balance
        balance = BigDecimal(0)
        balance += self.deposits.reduce(0){|sum, deposit| sum + deposit.amount}
        balance += self.withdrawals.reduce(0){|sum, withdrawal| sum + withdrawal.amount}
        balance += self.transfers.reduce(0){|sum, transfer| sum + transfer.amount}
        self.update_attributes(unconfirmed_balance: balance)
      end
  
      def update_confirmed_balance
        balance = BigDecimal(0)
        balance += self.deposits.where(confirmations: self.wallet.confirmations).reduce(0){|sum, deposit| sum + deposit.amount}
        balance += self.withdrawals.reduce(0){|sum, withdrawal| sum + withdrawal.amount}
        balance += self.transfers.reduce(0){|sum, transfer| sum + transfer.amount}
        self.update_attributes(confirmed_balance: balance)
      end

  end
end
