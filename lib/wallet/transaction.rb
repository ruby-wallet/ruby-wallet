module RubyWallet
  class Transaction
    include Mongoid::Document
    
    field :transaction_id,        type: String
    field :account_id,            type: String

    field :category,              type: String

    field :address,               type: String
    field :recipient_account,     type: String   

    field :amount,                type: BigDecimal

    field :confirmations,         type: Integer

    field :timestamp,             type: Time

    embedded_in :wallet

    validates_uniqueness_of :transaction_id

  end
end
