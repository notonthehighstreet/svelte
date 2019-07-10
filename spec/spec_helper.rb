# frozen_string_literal: true

require 'simplecov'

SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'svelte'
require 'json'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before :each do
    Svelte::Service.constants.each do |constant|
      Svelte::Service.send(:remove_const, constant)
    end
  end
end
