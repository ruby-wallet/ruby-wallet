require 'spec_helper'

describe Coind do
  include Coind

  before :each do
    FakeWeb.register_uri(:post, "http://user:pass@localhost:8332", :response => fixture('getbalance'))
  end
  
  it "as a function" do
    cli = Coind({:rpc_user => $user, :rpc_password => $pass, :rpc_host => 'localhost', :rpc_port => '8332', :rpc_ssl => false})
    expect(cli.balance).to eq(0.001)
  end
  
end

describe RubyWallet do
  include RubyWallet

  it "as a function" do
    cli = RubyWallet.connect("BLK")
    expect(cli.api.class).to eq("Ruby::Wallet")
  end

end
