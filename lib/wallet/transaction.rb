module RubyWallet
  class Transaction

    attr_reader(:account,
                :address,
                :recipient_account,
                :amount,
                :category,
                :confirmations,
                :id,
                :occurred_at,
                :received_at)

    def initialize(wallet, args)
      @wallet = wallet
      #@account = wallet.accounts.new(args[:account])
      @id = args["txid"] if args["txid"]
      @address = args["address"]
      @recipient_account = args["otheraccount"] if args["otheraccount"]
      @amount = args["amount"]
      @confirmations = args["confirmations"] if args["confirmations"]
      @occurred_at = Time.at(args["time"]) if args["time"]
      @received_at = Time.at(args["timereceived"]) if args["timereceived"]
      @category = args["category"]
    end

  end
end
