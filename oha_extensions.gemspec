# -*- encoding: utf-8 -*-
require File.expand_path('../lib/oha_extensions/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Bookrenter/Rafter"]
  gem.email         = ["cp@bookrenter.com"]
  gem.description   = %q{Extends Object, Hash and Array classes with additional methods.}
  gem.summary       = %q{Additional methods for Object, Hash, Array classes.}
  gem.homepage      = "https://github.com/bkr/oha_extensions"

  gem.add_development_dependency('mocha', '> 0')
  gem.add_development_dependency('shoulda', "> 0")
  gem.add_dependency('nokogiri', '> 0')

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "oha_extensions"
  gem.require_paths = ["lib"]
  gem.version       = OhaExtensions::VERSION
end
