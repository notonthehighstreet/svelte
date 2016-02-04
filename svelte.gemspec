# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'svelte/version'

Gem::Specification.new do |spec|
  spec.name          = 'svelte'
  spec.version       = Svelte::VERSION
  spec.authors       = ['notonthehighstreet.com']
  spec.email         = ['tech.contact@notonthehighstreet.com']

  spec.summary       = 'Dynamic Ruby API Client from Swagger JSON Spec'
  spec.description   = 'This gem consumes a Swagger API json file and maps the API into easy-to-use Ruby objects'
  spec.homepage      = 'https://github.com/notonthehighstreet/svelte'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'typhoeus'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rubocop'
end
