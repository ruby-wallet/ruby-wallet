require 'spec_helper'

describe Coind do
  include Coind

  it "as a function" do
    FakeWeb.register_uri(:post, "http://#{$coin['rpc_user']}:#{$coin['rpc_password']}@#{$coin['rpc_host']}:#{$coin['rpc_port']}", :response => fixture('getbalance'))
    cli = Coind($coind_options)
    expect(cli.balance).to eq(0.001)
  end
end

describe RubyWallet do
  include RubyWallet

  it "as a function" do
    cli = RubyWallet.connect($coin_iso)
    expect(cli).to be_a(RubyWallet::Wallet)
    expect(cli.iso_code).to eq($coin_iso)
  end
end
