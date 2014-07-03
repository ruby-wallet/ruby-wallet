# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bitcoin/version"

Gem::Specification.new do |s|
  s.name        = "ruby-wallet"
  s.version     = Bitcoin::VERSION
  s.authors     = ["oGminor"]
  s.email       = ["oGminor@gmail.com"]
  s.homepage    = "http://github.com/ruby-wallet/ruby-wallet"
  s.summary     = %q{Provides a Ruby library to the complete Bitcoin JSON-RPC API.}
  s.description = "Provides a Ruby library to the complete to any Bitcoin based cryptocurrency "+
                  "JSON-RPC API. Implements all methods listed at "+
                  "https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_Calls_list and "+
                  "lets you set options such as the host and port number, and whether to use SSL."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake",    '~> 0.8.7'
  s.add_development_dependency "bundler", '~> 1.0.18'
  s.add_development_dependency "rspec",   '~> 2.6.0'
  s.add_development_dependency "fakeweb", '~> 1.3.0'
  s.add_runtime_dependency "rest-client", '~> 1.6.3'
end
