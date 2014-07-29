require 'spec_helper'

describe Coind::Client do
  subject { Coind::Client.new({rpc_user: $user, rpc_password: $pass, rpc_host: 'localhost', rpc_port: 8332, rpc_ssl: false}) }

  it "defaults" do
    subject.user.should == $user
    subject.pass.should == $pass
    subject.host.should == 'localhost'
    subject.port.should == 8332
    subject.ssl?.should_not be_true
  end

  context "RPC" do
    extend RPCServiceHelper

    service 'getinfo' do
      it "should produce the expected result" do
        expect(result).to match_hash({
          'version' => 32400,
          'balance' => 0.001,
          'blocks' => 141957,
          'connections' => 8,
          'proxy' => "",
          'generate' => false,
          'genproclimit' => -1,
          'difficulty' => 1805700.83619367,
          'hashespersec' => 0,
          'testnet' => false,
          'keypoololdest' => 1313766189,
          'paytxfee' => 0.0,
          'errors' => ""
        })
      end
    end

    service 'getblockcount' do
      it "should produce the expected result" do
        expect(result).to be eq(141972)
      end
    end

    service 'getconnectioncount' do
      it "should produce the expected result" do
        expect(result).to be eq(8)
      end
    end

    service 'gethashespersec' do
      it "should produce the expected result" do
        expect(result).to be eq(0)
      end
    end

    service 'listreceivedbyaddress' do
      context 'without params' do
        it "should produce the expected result" do
          expect(result).to match_array([{
            'address' => "1234",
            'account' => "",
            'label' => "",
            'amount' => 0.001,
            'confirmations' => 180}])
        end
      end

      context 'with minconf 0' do
        it "should produce the expected result" do
          expect(result(0)).to match_array([{
            'address' => "1234",
            'account' => "",
            'label' => "",
            'amount' => 0.001,
            'confirmations' => 180}])
        end
      end

      context 'with minconf 0 and includeempty true' do
        it "should produce the expected result" do
          expect(result(0, true)).to match_array([{
            'address' => "1234",
            'account' => "",
            'label' => "",
            'amount' => 0.001,
            'confirmations' => 180}])
        end
      end
    end

    service 'signmessage' do
      context 'success' do
        it "should produce the expected result" do
          expect(result('valid_address', 'message')).to eq('Gwz2BAaqdsLTqJsh5a4')
        end
      end
    end

    service 'verifymessage' do
      context 'success' do
        it "should produce the expected result" do
          expect(result('address', 'message', 'signature')).to eq(true)
        end
      end

      context 'failure' do
        it "should produce the expected result" do
          expect(result('address', 'message', 'signature')).to eq(false)
        end
      end
    end
  end
end
