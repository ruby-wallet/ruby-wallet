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
    field :confirmed,             type: Boolean,    default: false

    field :occurred_at,           type: Time
    field :received_at,           type: Time

    embedded_in :wallet

    validates_uniqueness_of :transaction_id
    validates_numericality_of :amount, greater_than: 0
    validates :amount, format: { with: /\A\d{0,8}(\.\d{1,8}|)\z/ }

    def account
      wallet.accounts.find(account_id)
    end

    def confirm
      if confirmations >= wallet.confirmations
        update_attributes(confirmed: true)
      end
    end

    def confirmed?
      confirmed
    end

    def timestamp
      if occurred_at
        occurred_at
      else
        received_at
      end
    end

  end
end
