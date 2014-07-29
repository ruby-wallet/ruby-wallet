require 'spec_helper'

describe Coind::API do
  subject { Coind::API.new($coind_options) }

  it "accepts rpc_user, rpc_password, rpc_host, rpc_port, rpc_ssl options" do
    req = Coind::API.new($coind_options)
    expect(req.to_hash[:rpc_user]).to eq('user')
    expect(req.to_hash[:rpc_password]).to eq('pass')
    expect(req.to_hash[:rpc_host]).to eq('localhost')
    expect(req.to_hash[:rpc_port]).to eq(8332)
    expect(req.to_hash[:rpc_ssl]).to eq(false)
  end
end
