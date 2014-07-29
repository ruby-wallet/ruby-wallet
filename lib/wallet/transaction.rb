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
    field :confirmed,             type: Boolean

    field :occurred_at,           type: Time
    field :received_at,           type: Time

    embedded_in :wallet

    validates_uniqueness_of :transaction_id
    validates_numericality_of :amount, greater_than: 0
    validates :amount, format: { with: /^\d{0,8}(\.\d{1,8}|)/ }

    def account
      self.wallet.accounts.find(account_id)
    end

    def confirm
      if self.confirmations >= self.wallet.confirmations
        self.update_attributes(confirmed: true)
      end
    end

    def confirmed?
      self.confirmed
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
