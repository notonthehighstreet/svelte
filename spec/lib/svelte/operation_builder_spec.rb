require 'spec_helper'

describe Svelte::OperationBuilder do
  let(:operation_id) { 'operationId' }
  let(:method_name) { 'operation_id' }
  let(:verb) { 'get' }
  let(:path) { double(:path) }
  let(:operation) do
    double(:operation,
           id: operation_id,
           path: path,
           verb: verb)
  end
  let(:module_constant) { Module.new }
  let(:base_path) { '/' }
  let(:host) { 'localhost' }
  let(:request_parameter) { 'request_parameter' }
  let(:protocol) { 'http' }
  let(:configuration) do
    double(:configuration,
           host: host,
           base_path: base_path,
           middleware_stack: [],
           protocol: protocol)
  end

  before do
    described_class.build(operation: operation,
                          module_constant: module_constant,
                          configuration: configuration)
  end

  it 'creates a method on the module' do
    expect(module_constant).to respond_to(method_name)
  end

  context 'when invoking the method without options' do
    let(:parameters) do
      {
        request_parameter: request_parameter
      }
    end

    it 'calls the GenericOperation class when the new method is invoked' do
      expect(Svelte::GenericOperation).to receive(:call).with(
        verb: verb,
        path: path,
        configuration: configuration,
        parameters: { 'request_parameter' => request_parameter },
        options: {middleware_stack: []})

      module_constant.public_send(method_name, parameters)
    end
  end

  context 'when invoking the method with options' do
    let(:parameters) do
      {
        request_parameter: request_parameter
      }
    end

    let(:options) do
      {
        timeout: 10
      }
    end

    it 'calls the GenericOperation class when the new method is invoked' do
      expect(Svelte::GenericOperation).to receive(:call).with(
        verb: verb,
        path: path,
        configuration: configuration,
        parameters: { 'request_parameter' => request_parameter },
        options: options)

      module_constant.public_send(method_name, parameters, options)
    end
  end

  context 'when invoking the method without arguments' do
    it 'calls the GenericOperation class when the new method is invoked' do
      expect(Svelte::GenericOperation).to receive(:call).with(
        verb: verb,
        path: path,
        configuration: configuration,
        parameters: {},
        options: {middleware_stack: []}
      )

      module_constant.public_send(method_name)
    end
  end
end
