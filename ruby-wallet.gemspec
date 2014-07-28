# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name        = "ruby-wallet"
  s.version     = RubyWallet::VERSION
  s.authors     = ["oGminor", "drunkonsound"]
  s.email       = ["admin@blackwavelabs.com"]
  s.homepage    = "http://github.com/ruby-wallet/ruby-wallet"
  s.summary     = %q{A Ruby API wrapper and account manager abstraction for any Bitcoin based crypto currency.}
  s.description = "Provides a Ruby API wrapper and account manager to any Bitcoin based coind client."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "rest-client"
end
