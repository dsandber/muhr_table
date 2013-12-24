# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'muhr_table/version'

Gem::Specification.new do |spec|
  spec.name          = "muhr_table"
  spec.version       = MuhrTable::VERSION
  spec.authors       = ["Dan Sandberg"]
  spec.email         = ["dan.sandberg+muhr_table@google.com"]
  spec.summary       = "Easily create tables from any data source with filtering and sorting."
  spec.description   = "Easily create tables from any data source with filtering and sorting." + 
                       " Backends supported are ActiveRecord and Array-backed.  Plugging in new" +
                       " backends is easy.  The goal is to get you up and running as fast as possible while" +
  		       " being completely customizable.  The code is clean and modular so that " +
  		       " new features can be quickly implemented"
                    		       
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
