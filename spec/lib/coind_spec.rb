require 'spec_helper'

describe Coind do
  before :each do
    FakeWeb.register_uri(:post, "http://user:pass@localhost:8332", :response => fixture('getbalance'))
  end
  
  it "as a function" do
    cli = Coind($user, $pass)
    cli.balance.should == 0.001
  end
  
end
