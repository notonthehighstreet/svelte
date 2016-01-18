require 'spec_helper'

describe Svelte::PathBuilder do
  let(:json) { JSON.parse(File.read('spec/fixtures/petstore.json')) }
  let(:non_parameter_elements) { %w(store inventory) }
  let(:path) { double(:path, non_parameter_elements: non_parameter_elements) }
  let(:module_constant) { Module.new }

  before do
    described_class.build(path: path, module_constant: module_constant)
  end

  it 'builds the right module hierarchy' do
    expect(module_constant.const_defined?('Store::Inventory')).to eq(true)
  end
end
