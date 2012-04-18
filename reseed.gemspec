# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "reseed/version"

Gem::Specification.new do |s|
  s.name        = "reseed"
  s.version     = Reseed::VERSION
  s.authors     = ["joseph.andaverde"]
  s.email       = ["joseph.andaverde@softekinc.com"]
  s.homepage    = ""
  s.summary     = %q{Reseeds dependencies}
  s.description = %q{Reseeds dependencies and automatically checks out files in TFS if necessary.}

  s.rubyforge_project = "reseed"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "mocha"
  s.add_development_dependency "fakeweb"
  
  # s.add_runtime_dependency "rest-client"
end
