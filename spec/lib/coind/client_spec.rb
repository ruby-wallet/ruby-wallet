require "spec_helper"

describe Coind::Client do
  subject { Coind::Client.new($coind_options) }

  context "RPC" do
    extend RPCServiceHelper

    service "getinfo" do
      it "returns the coind info" do
        expect(result("getinfo")).to eq({
          "version" => 32400,
          "balance" => 0.001,
          "blocks" => 141957,
          "connections" => 8,
          "proxy" => "",
          "generate" => false,
          "genproclimit" => -1,
          "difficulty" => 1805700.83619367,
          "hashespersec" => 0,
          "testnet" => false,
          "keypoololdest" => 1313766189,
          "paytxfee" => 0.0,
          "errors" => ""
        })
      end
    end

    service "getblockcount" do
      it "returns the block count" do
        expect(result("getblockcount")).to eq(141972)
      end
    end

    service "getconnectioncount" do
      it "returns the connection count" do
        expect(result("getconnectioncount")).to eq(8)
      end
    end

    service "listreceivedbyaddress" do
      context "without params" do
        it "returns an array trasactions" do
          expect(result("listreceivedbyaddress_without_params")).to match_array([{
            "address" => "1234",
            "account" => "",
            "label" => "",
            "amount" => 0.001,
            "confirmations" => 180}])
        end
      end

      context "with minconf 0" do
        it "returns an array of transactions" do
          expect(result("listreceivedbyaddress_with_minconf_0", 0)).to match_array([{
            "address" => "1234",
            "account" => "",
            "label" => "",
            "amount" => 0.001,
            "confirmations" => 180}])
        end
      end

      context "with minconf 0 and includeempty true" do
        it "returns an array of transactions" do
          expect(result("listreceivedbyaddress_with_minconf_0_and_includeempty_true", 0, true)).to match_array([{
            "address" => "1234",
            "account" => "",
            "label" => "",
            "amount" => 0.001,
            "confirmations" => 180}])
        end
      end
    end

    service "signmessage" do
      context "success" do
        it "returns a valid address" do
          expect(result("signmessage_success", "valid_address", "message")).to eq("Gwz2BAaqdsLTqJsh5a4")
        end
      end
    end

    service "verifymessage" do
      context "success" do
        it "returns true when message is verified" do
          expect(result("verifymessage_success", "address", "message", "signature")).to eq(true)
        end
      end

      context "failure" do
        it "returns false when message is unverifiable" do
          expect(result("verifymessage_failure", "address", "message", "signature")).to eq(false)
        end
      end
    end
  end
end
