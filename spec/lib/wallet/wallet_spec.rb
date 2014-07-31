require 'spec_helper'

describe RubyWallet::Wallet do
  extend RPCServiceHelper
  subject { RubyWallet.connect($coin_iso) }

  it "returns a Mongoid object" do
    expect(subject).to be_a(RubyWallet::Wallet)
    expect(subject.id).to be_a(Moped::BSON::ObjectId)
  end

  it "returns Wallet object with expected iso_code" do
    expect(subject.iso_code).to eq($coin_iso)
  end

  it "returns Wallet object with basic configuration from coins.yml" do
    expect(subject.rpc_user).to be_a(String)
    expect(subject.rpc_user).to_not eq(nil)

    expect(subject.rpc_password).to be_a(Mongoid::EncryptedString)
    expect(subject.rpc_password).to_not eq(nil)

    expect(subject.rpc_host).to be_a(String)
    expect(subject.rpc_host).to_not eq(nil)

    expect(subject.rpc_port).to be_a(Fixnum)
    expect(subject.rpc_port).to_not eq(nil)

    expect(subject.rpc_ssl).to be_a(FalseClass).or be_a(TrueClass) 
    expect(subject.rpc_ssl).to_not eq(nil)

    expect(subject.wallet_password).to be_a(Mongoid::EncryptedString)
    expect(subject.wallet_password).to_not eq(nil)

    expect(subject.confirmations).to be_a(Fixnum)
    expect(subject.confirmations).to_not eq(nil)
  end

  context "Coind API" do
    service "valid_address?" do
      it "connects to Coind API to validate an address" do 
       expect(result("validateaddress", $coin_address)).to be_a(TrueClass).or be_a(FalseClass)
      end
    end

    service "own_address?" do
      it "connects to Coind API to validate address ownership" do 
        expect(result("validateaddress", $coin_address)).to be_a(TrueClass).or be_a(FalseClass)
      end
    end

    it "creates an account when given a label" do
      expect(subject.create_account($account_label)).to be_a(RubyWallet::Account)
      expect(subject.accounts.find_by(label: $account_label).label).to eq($account_label)
      expect(subject.accounts.find_by(label: $account_label).addresses.count).to eq(1)
    end

    context "Generate new address for an account" do
      service "generate_address" do
        it "creates an address for an account" do 
          @generated_address = result("getnewaddress", $account_label)
          expect(@generated_address).to be_a(String)  
        end
      end
  
      service "own_address?" do 
        it "connects to Coind API to validate generated address ownership" do
          expect(result("validateaddress", @generated_address)).to be_a(TrueClass)
        end
      end
  
      service "label" do
        it "connects to Coind API to return account label for generated address" do
          expect(result("validateaddress", @generated_address)).to eq($account_label)
        end
      end 
    end

    service "withdraw" do
      context "account and wallet have enough coins to withdraw" do
        let(:account) { subject.create_account($account_label) }
        
        before do
          account.confirmed_balance = 50
          subject.confirmed_balance = 50
        end
        
        it "connects to Coind API to withdraw funds and returns a txid" do
          expect(result("sendtoaddress", account, $coin_address, 50)).to eq($test_txid)
        end
      end

      context "account does not have enough coins but wallet does" do
        let(:account) { subject.create_account($account_label) }

        before do
          subject.confirmed_balance = 50
        end

        it "connects to Coind API to withdraw funds and returns a txid" do
          expect(result("sendtoaddress", account, $coin_address, 50)).to eq(false)
        end
      end
    end

    # Doesn't properly test the total_received since Fakeweb does not read the request body and distinguish different POST request to same URI
    # but it tests important functionality. This request requires 3 separate API calls.
    it "connects to Coind API to save recent transactions within the wallet object" do
      FakeWeb.register_uri(:post, "http://#{$coin['rpc_user']}:#{$coin['rpc_password']}@#{$coin['rpc_host']}:#{$coin['rpc_port']}", :response => fixture('listtransactions'))
      subject.sync
      first_checked_count = subject.transaction_checked_count
      expect(subject.transactions.count).to eq(subject.account($account_label).deposit_ids.count)
      subject.sync
      expect(first_checked_count).to eq(subject.transaction_checked_count)
      expect(subject.transactions.count).to eq(subject.account($account_label).deposit_ids.count)
    end

    it "connects to Coind API to obtain updates on a transaction" do
      FakeWeb.register_uri(:post, "http://#{$coin['rpc_user']}:#{$coin['rpc_password']}@#{$coin['rpc_host']}:#{$coin['rpc_port']}", :response => fixture('gettransaction'))
      transaction = subject.transaction("eb8cd2a634b36186cb7c548d297abbb9005c9e9467210138375e1241f5a06f6c")
      expect(transaction.confirmations).to be > 10
      transaction.update_attributes(confirmations: 0, confirmed: false)
      subject.sync_transaction("eb8cd2a634b36186cb7c548d297abbb9005c9e9467210138375e1241f5a06f6c")
      transaction = subject.transaction("eb8cd2a634b36186cb7c548d297abbb9005c9e9467210138375e1241f5a06f6c")
      expect(transaction.confirmations).to be > 10
      expect(transaction.confirmed).to be true
      subject.account($account_label).update_balances
    end
 
    context "wallet embeds many transactions which have helper methods" do
      let(:transaction) { subject.transactions.first }

      it "returns a Time object when timestamp is called on embedded transaction" do
        expect(transaction.timestamp).to_not be nil
      end
 
      it "returns false when unconfirmed" do
        transaction.update_attributes(confirmations: 0, confirmed: false)
        expect(transaction.confirmed?).to be false
      end
 
      it "returns true if confirmed" do
        transaction.update_attributes(confirmations: 1400)
        transaction.confirm
        expect(transaction.confirmed?).to be true
      end
 
    end
  end

  context "account management" do
    let(:sender_account) { subject.account($account_label) } 
    let(:recipient_account) { subject.create_account("recipient") }

    it "transfers coins from one account to another" do
      subject.confirmed_balance = BigDecimal.new("38411.97369153") # Because we can't make more than 1 API call per method because fakeweb
      sender_starting_balance = sender_account.confirmed_balance
      subject.transfer(sender_account, recipient_account, 250)

      expect(subject.transfers.count).to eq(2)
      expect(sender_account.transfers.reduce(0){|sum, transfer| sum + transfer.amount}).to eq(BigDecimal.new(-250))
      expect(recipient_account.transfers.reduce(0){|sum, transfer| sum + transfer.amount}).to eq(250)
      expect(sender_account.transfers.count).to eq(1)
      expect(recipient_account.transfers.count).to eq(1)
      expect(recipient_account.confirmed_balance).to eq(250)
      expect(sender_starting_balance).to eq((sender_account.confirmed_balance + BigDecimal.new(250)))
    end

    it "returns the total received for the account" do
      FakeWeb.register_uri(:post, "http://#{$coin['rpc_user']}:#{$coin['rpc_password']}@#{$coin['rpc_host']}:#{$coin['rpc_port']}", :response => fixture('getreceivedbylabel'))
      expect(subject.total_received($account_label)).to eq(24029.43552541) # Different from others because I customized the transactions fixture to include more transactions.
    end
  end
end
