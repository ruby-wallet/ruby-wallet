module RubyWallet
  class Transaction
    include Mongoid::Document

    field :transaction_id,        type: String
    field :account_label,         type: String

    field :category,              type: String
    field :address,               type: String
    field :amount,                type: BigDecimal
    field :confirmations,         type: Integer
    field :confirmed,             type: Boolean,    default: false

    field :comment,               type: String

    field :occurred_at,           type: Time
    field :received_at,           type: Time

    embedded_in :wallet

    validates_uniqueness_of :transaction_id
    validates :category, format: { with: /\A(send|receive)\z/ }
    validates :amount, format: { with: /\A(-|)\d{0,8}(\.\d{1,8}|)\z/ }
    validate  :amount_check

    def account
      wallet.account(account_label)
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

    protected

      def amount_check
        if category == "send"
          amount > BigDecimal.new(0)
        else
          amount < BigDecimal.new(0)
        end
      end
  end
end
