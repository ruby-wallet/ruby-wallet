module RubyWallet
  class Transfer
    include Mongoid::Document

    field :timestamp,      type: Time

    field :sender_id,      type: String
    field :recipeint_id,   type: String

    field :amount,         type: String
       
    field :comment,        type: String

    embedded_in :wallet

    def sender
      self.wallet.accounts.find(self.sender_id)
    end

    def recipient
      self.wallet.accounts.find(self.recipient_id)
    end

  end
end
