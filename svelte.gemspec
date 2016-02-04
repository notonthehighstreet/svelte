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
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.0'

  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'faraday_middleware', '~> 0.10'
  spec.add_dependency 'typhoeus', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'redcarpet', '~> 3.3'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'webmock', '~> 1.22'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'rubocop', '~> 0.36'
end
