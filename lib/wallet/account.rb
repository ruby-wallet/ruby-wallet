module RubyWallet
  class Account
    include Mongoid::Document

    field :account_id,           type: String
    field :account_label,        type: String

    field :addresses,            type: Array

    field :unconfirmed_balance,  type: BigDecimal
    field :confirmed_balance,    type: BigDecimal
    field :total_received,       type: BigDecimal

    embedded_in :wallet

    def deposits
      transactions.where(category: "deposit")
    end

    def withdrawals
      transactions.where(category: "withdrawal")
    end

    def generate_new_address
      Address.new(self)
      # Add address to array
    end

    def send_to_address(amount, address)
      # 1. Confirm amount
      # 2. Confirm address is legit
      # 3. Send money
    end

    def transfer_to(amount, recipient)
      # 1. Confirm amount
      # 2. Confirm recipient is real
      # 3. Send money within internal database and create two transfers (double book keeping, -x amount from sender account +x amount to recipient account)
    end

    protected

      def populate_transactions(from = 0, to)
        #@wallet.transactions(@name, to, from)
      end


  end
end
