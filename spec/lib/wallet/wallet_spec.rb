require 'spec_helper'

describe RubyWallet::Wallet do
  subject { RubyWallet.connect($coin) }

  it "returns a Mongoid object" do
    expect(subject.class).to eq(RubyWallet::Wallet)
    expect(subject.id.class).to eq(Moped::BSON::ObjectId)
  end

  it "returns Wallet object with expected iso_code" do
     expect(subject.iso_code).to eq($coin)
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

  it "connects to Coind API to validate an address" do 
    expect(subject.valid_address?($coin_address)).to be_a(String)
  end

  it "connects to Coind API to validate address ownership" do 
    expect(subject.own_address?($coin_address)).to be_a(String)
  end

  it "creates an account when given a label" do 
    expect(subject.valid_address?($coin_address)).to be_a(String)
  end

  

end
