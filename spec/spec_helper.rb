require 'fakeweb'
require 'yaml'

ENV['ENV'] = "test"
require 'ruby-wallet'

# Clean test database
RubyWallet::Wallet.all.destroy

# RubyWallet settings
$coin_iso = "BLK"
$coin_address = "B98Z9DEnTtbYMWZF33iPKjF2LqQa1QUbvq"
$account_label = "test"

# Load coins.yml configuration for tests
begin
  $coin = YAML::load_file(File.expand_path("../../config/coins.yml", __FILE__))[$coin_iso][ENV['ENV']]
rescue
  system "echo 'You must copy sample config files in the config folder to create config files."
end

# Coind settings
$coind_options = {:rpc_user => $coin['rpc_user'],
                  :rpc_password => $coin['rpc_password'],
                  :rpc_host => $coin['rpc_host'],
                  :rpc_port => $coin['rpc_port'],
                  :rpc_ssl => $coin['rpc_ssl']
                 }
$test_txid = "b64345d4dd2d71f34a5968f9f28c5a36a2069e20d85d772482aebdb9e040e9ae"

require File.expand_path('../lib/ruby-wallet.rb', File.dirname(__FILE__))

Dir[File.expand_path("support/**/*.rb", File.dirname(__FILE__))].each { |f| require f }

# Fakeweb doesn't work for RubyWallet tests since some requests require two POST to the same URL with different
# parmaters and the post body is ignored by fakeweb
FakeWeb.allow_net_connect = false

RSpec.configure do |c|
  c.include FixturesHelper
end
