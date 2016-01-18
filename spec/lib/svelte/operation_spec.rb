require 'spec_helper'

describe Svelte::Operation do
  let(:operation_id) { 'operationId' }
  let(:properties) do
    {
      'operationId' => operation_id
    }
  end
  let(:path) { double(:path) }
  let(:verb) { 'get' }

  subject do
    described_class.new(verb: verb, properties: properties, path: path)
  end

  it 'has a verb' do
    expect(subject.verb).to eq(verb)
  end

  it 'has an id' do
    expect(subject.id).to eq(operation_id)
  end

  it 'has a path' do
    expect(subject.path).to eq(path)
  end
end
