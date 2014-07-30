require 'fakeweb'
require 'yaml'

ENV['ENV'] = "test"

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

require File.expand_path('../lib/ruby-wallet.rb', File.dirname(__FILE__))

Dir[File.expand_path("support/**/*.rb", File.dirname(__FILE__))].each { |f| require f }

FakeWeb.allow_net_connect = false

RSpec.configure do |c|
  c.include FixturesHelper
end
