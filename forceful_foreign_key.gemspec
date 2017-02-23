# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'forceful_foreign_key/version'

Gem::Specification.new do |spec|
  spec.name          = "forceful_foreign_key"
  spec.version       = ForcefulForeignKey::VERSION
  spec.authors       = ["shaw3257"]
  spec.email         = ["shaw3257@gmail.com"]

  spec.summary       = "ActiveRecord extension that adds an option to add_foreign_key to delete orphaned data."
  spec.description   = "When force: true is set, It will delete orphaned data before applying the foreign
                        key constraint. Use cautiously!"
  spec.homepage      = "https://github.com/viewthespace/forceful-foreign-key"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency('activerecord', '>= 3.0')

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "pry"
end
