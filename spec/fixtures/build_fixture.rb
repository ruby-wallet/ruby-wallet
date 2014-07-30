#!/usr/bin/env ruby

require 'yaml'
require 'json'

$coin_iso = "BLK"
ENV['ENV'] = "test"

$coin = YAML::load_file(File.expand_path("../../../config/coins.yml", __FILE__))[$coin_iso][ENV['ENV']]

service_name = ARGV[0]
file_name = (ARGV[1] || service_name).dup
params = ARGV[2..-1].collect { |y| y == '_nil' ? nil : YAML::load(y) }

file_name << ".json" unless file_name =~ /\.json$/

data = { 'jsonrpc' => '1.0', 'id' => 'curltest', 'method' => service_name, 'params' => params }
command = "curl --user #{$coin['rpc_user']}:#{$coin['rpc_password']} --data-binary '#{data.to_json}' -H 'content-type: text/plain;' http#{'s' if $coin['rpc_ssl']}://#{$coin['rpc_host']}:#{$coin['rpc_port']}/ -i"

puts command, nil
result = %x[#{command}]
puts result, nil
File.open(file_name, "w") { |f| f.print result }

