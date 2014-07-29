require 'spec_helper'

describe Coind::API do
  subject { Coind::API.new({:rpc_user => $user, :rpc_password => $pass, rpc_host: 'example.com', rpc_port: 1234, rpc_ssl: true}) }

  it "should accept rpc_user, rpc_password, rpc_host, rpc_port, rpc_ssl options" do
    req = Coind::API.new({rpc_user: $user, rpc_password: $pass, rpc_host: 'example.com', rpc_port: 1234, rpc_ssl: true})
    req.rpc_user.should == $user
    req.rpc_password.should == $pass
    req.rpc_host.should == 'example.com'
    req.rpc_port.should == 1234
    req.rpc_ssl?.should be_true
  end

  it "should build an options hash" do
    expect(subject.to_hash).to match_hash({
      :rpc_user => $user,
      :rpc_password => $pass,
      :rpc_host => 'example.com',
      :rpc_port => 1234,
      :rpc_ssl => true,
    })
  end
end
