module RubyWallet
  class Accounts < Array

    def with_balance
      self.detect { |a| a.balance > 0 }
    end

    def initialize(wallet)
      @wallet = wallet
      @wallet.listaccounts.each do |account|
        self.push(Account.new(@wallet, account[0]))
      end
    end

    def new(name)
      if self.includes_account_name?(name)
        account = self.detect {|a| a.name == name}
      else
        account = Account.new(@wallet, name)
        account.generate_new_address
        self << account
      end
      account
    end

    def includes_account_name?(account_name)
      self.detect {|a| a.name == account_name}.present?
    end

    def where_account_name(account_name)
      self.detect {|a| a.name == account_name}
    end

    private

    def existing_accounts
      @wallet.client.listaccounts.keys
    end

  end
end
