module RubyWallet
  class Transfer
    include Mongoid::Document

    field :timestamp,      type: Time

    field :sender_id,      type: String
    field :recipeint_id,   type: String

    field :category,       type: String
    field :amount,         type: String
       
    field :comment,        type: String

    embedded_in :wallet

    validates_numericality_of :amount, greater_than: 0
    validates :amount, format: { with: /^\d{0,8}(\.\d{1,8}|)/ }
    validates :category, format: { with: /^(send|receive)$/ }

    def sender
      self.wallet.accounts.find(self.sender_id)
    end

    def recipient
      self.wallet.accounts.find(self.recipient_id)
    end

  end
end
