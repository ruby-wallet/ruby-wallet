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
    end
  
    it "creates an address for an account" do 
      expect(subject.generate_address($account_label)).to be_a(String)
    end
  end
end
