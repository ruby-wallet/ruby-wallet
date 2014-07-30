require 'spec_helper'

describe Coind::API do
  subject { Coind::API.new($coind_options) }

  it "accepts rpc_user, rpc_password, rpc_host, rpc_port, rpc_ssl options" do
    req = Coind::API.new($coind_options)
    expect(req.to_hash[:rpc_user]).to eq($coin['rpc_user'])
    expect(req.to_hash[:rpc_password]).to eq($coin['rpc_password'])
    expect(req.to_hash[:rpc_host]).to eq($coin['rpc_host'])
    expect(req.to_hash[:rpc_port]).to eq($coin['rpc_port'])
    expect(req.to_hash[:rpc_ssl]).to eq($coin['rpc_ssl'])
  end
end
