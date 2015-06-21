# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'squirrell/version'

Gem::Specification.new do |spec|
  spec.name          = 'squirrell'
  spec.version       = Squirrell::VERSION
  spec.authors       = ['Matt Parsons']
  spec.email         = ['parsonsmatt@gmail.com']

  spec.summary       = 'A kinda magical gem for query objects'
  spec.homepage      = 'https://www.github.com/parsonsmatt/squirrell'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'guard', '~> 2.12'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'guard-rspec', '~> 4.5'
  spec.add_development_dependency 'rubocop'
end
