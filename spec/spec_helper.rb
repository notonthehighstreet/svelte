require 'simplecov'

SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'svelte'
require 'byebug'
require 'json'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before :each do
    Svelte::Service.constants.each do |constant|
      Svelte::Service.send(:remove_const, constant)
    end
  end
end
