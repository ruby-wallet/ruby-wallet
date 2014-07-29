module RubyWallet
  class Transfer
    include Mongoid::Document

    field :timestamp,      type: Time

    field :sender_id,      type: String
    field :recipeint_id,   type: String

    field :amount,         type: String
       
    field :comment,        type: String

    embedded_in :wallet

  end
end
