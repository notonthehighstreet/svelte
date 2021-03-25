# frozen_string_literal: true

require 'spec_helper'

describe Svelte::OperationBuilder do
  let(:operation_id) { 'operationId' }
  let(:method_name) { 'operation_id' }
  let(:verb) { 'get' }
  let(:path) { double(:path) }
  let(:properties) { {"parameters" => []} }
  let(:operation) do
    double(:operation,
           id: operation_id,
           path: path,
           verb: verb,
           properties: properties)
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
        headers: {},
        configuration: configuration,
        parameters: { 'request_parameter' => request_parameter },
        options: {}
      )

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
        headers: {},
        configuration: configuration,
        parameters: { 'request_parameter' => request_parameter },
        options: options
      )

      module_constant.public_send(method_name, parameters, options)
    end
  end

  context 'when invoking the method without arguments' do
    it 'calls the GenericOperation class when the new method is invoked' do
      expect(Svelte::GenericOperation).to receive(:call).with(
        verb: verb,
        path: path,
        headers: {},
        configuration: configuration,
        parameters: {},
        options: {}
      )

      module_constant.public_send(method_name)
    end
  end

  context 'when invoking a method that uses headers' do
    let(:method) { 'get' }
    let(:parameters) do
      [
        {
          "in" => "header",
          "name" => "authorization"
        },
        {
          "in" => "body",
          "name" => "foo"
        }
      ]
    end

    let(:properties) { {"parameters" => parameters} }

    let(:request_parameters) do
      {
        authorization: 'foo',
        foo: 'bar'
      }
    end

    let(:operation) do
      double(:operation,
             id: operation_id,
             path: path,
             verb: verb,
             properties: properties)
    end

    before do
      described_class.build(operation: operation,
                            module_constant: module_constant,
                            configuration: configuration)
    end

    it 'calls GenericOperation class with headers' do
      expect(Svelte::GenericOperation).to receive(:call).with(
        verb: method,
        path: path,
        parameters: { 'foo' => 'bar' },
        headers: { 'authorization' => 'foo' },
        configuration: configuration,
        options: {}
      )

      module_constant.public_send(method_name, request_parameters)
    end

  end
end
