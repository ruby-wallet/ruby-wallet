require 'spec_helper'

describe Coind::API do
  subject { Coind::API.new({:rpc_user => 'user', :rpc_password => 'pass', rpc_host: 'example.com', rpc_port: 1234, rpc_ssl: true}) }

  it "should accept rpc_user, rpc_password, rpc_host, rpc_port, rpc_ssl options" do
    req = Coind::API.new({rpc_user: $user, rpc_password: $pass, rpc_host: 'example.com', rpc_port: 1234, rpc_ssl: true})
    expect(req.to_hash[:rpc_user]).to eq('user')
    expect(req.to_hash[:rpc_password]).to eq('pass')
    expect(req.to_hash[:rpc_host]).to eq('example.com')
    expect(req.to_hash[:rpc_port]).to eq(1234)
    expect(req.to_hash[:rpc_ssl]).to eq(true)
  end
end
