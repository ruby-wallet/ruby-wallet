require 'fakeweb'

# coind settings
$coind_options = {:rpc_user => 'user', :rpc_password => 'pass', :rpc_host => 'localhost', :rpc_port => 8332, :rpc_ssl => false}

# ruby-wallet settings
$coin = "BLK"
$coin_address = "B98Z9DEnTtbYMWZF33iPKjF2LqQa1QUbvq"

$account_label = "test"

require File.expand_path('../lib/ruby-wallet.rb', File.dirname(__FILE__))

Dir[File.expand_path("support/**/*.rb", File.dirname(__FILE__))].each { |f| require f }

FakeWeb.allow_net_connect = false

RSpec.configure do |c|
  c.include FixturesHelper
end
