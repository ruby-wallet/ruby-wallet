module RubyWallet
  class Transaction
    include Mongoid::Document

    field :transaction_id,        type: String

    field :account_label,         type: String
    field :account_id,            type: String

    field :category,              type: String
    field :address,               type: String
    field :amount,                type: BigDecimal
    field :confirmations,         type: Integer

    field :occurred_at,           type: Time
    field :received_at,           type: Time

    embedded_in :wallet

    validates_uniqueness_of :transaction_id

    def account
      self.wallet.accounts.find(account_id)
    end

    def timestamp
      if occurred_at
        self.occured_at
      else
        self.received_at
      end
    end

  end
end
