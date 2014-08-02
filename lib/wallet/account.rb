module RubyWallet
  class Account
    include Mongoid::Document

    field :label,                type: String
    field :addresses,            type: Array,         default: []

    field :unconfirmed_balance,  type: BigDecimal,    default: 0
    field :confirmed_balance,    type: BigDecimal,    default: 0

    field :total_received,       type: BigDecimal,    default: 0

    field :withdrawal_ids,       type: Array,         default: []
    field :deposit_ids,          type: Array,         default: []

    embedded_in :wallet

    validates_uniqueness_of :label

    after_create :generate_address

    def generate_address
      address = wallet.generate_address(label)
      update_attributes(addresses: addresses.push(address).uniq)
      addresses.last
    end

    def transfers
      wallet.transfers.any_of({sender_label: label, category: "send"}, {recipient_label: label, category: "receive"})
    end

    def transactions
      wallet.transactions.where(account_label: label)
    end

    def deposits
      transactions.where(category: "receive")
    end

    def confirmed_deposits
      deposits.where(confirmed: true)
    end

    def withdrawals
      transactions.where(category: "send")
    end

    def withdraw(address, amount)
      wallet.withdraw(self, address, amount)
    end

    def transfer(recipient_label, amount, comment = nil)
      recipient = wallet.accounts.find_by(label: recipient_label)
      if recipient
        wallet.transfer(self, recipient, amount, comment)
      else
        false
      end
    end

    def update_balances
      update_unconfirmed_balance
      update_confirmed_balance
    end

    def update_unconfirmed_balance
      balance = BigDecimal(0)
      balance += deposits.reduce(0){|sum, deposit| sum + deposit.amount}
      balance += withdrawals.reduce(0){|sum, withdrawal| sum + withdrawal.amount}
      balance += transfers.reduce(0){|sum, transfer| sum + transfer.amount}
      update_attributes(unconfirmed_balance: balance)
    end

    def update_confirmed_balance
      balance = BigDecimal.new(0)
      balance += confirmed_deposits.reduce(0){|sum, deposit| sum + deposit.amount}
      balance += withdrawals.reduce(0){|sum, withdrawal| sum + withdrawal.amount}
      balance += transfers.reduce(0){|sum, transfer| sum + transfer.amount}
      update_attributes(confirmed_balance: balance)
    end
  end
end
