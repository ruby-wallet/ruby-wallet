require 'spec_helper'

describe Coind do
  include Coind

  before :each do
    FakeWeb.register_uri(:post, "http://user:pass@localhost:8332", :response => fixture('getbalance'))
  end
  
  it "as a function" do
    cli = Coind($coind_options)
    expect(cli.balance).to eq(0.001)
  end
  
end

describe RubyWallet do
  include RubyWallet

  it "as a function" do
    cli = RubyWallet.connect($coin)
    expect(cli).to be_a(RubyWallet::Wallet)
    expect(cli.iso_code).to eq($coin)  
  end

end
