# frozen_string_literal: true

require 'spec_helper'
require 'svelte/model_factory'

class ModelFactoryTest
  extend Svelte::ModelFactory
end

describe ModelFactoryTest do
  let(:test_model_class) { :TestModel }
  let(:nested_model_class) { :NestedModel }
  let(:nested_model_name) { 'My name' }
  let(:nested_model_instance) { ModelFactoryTest::NestedModel.new }
  let(:another_nested_model_instance) do
    ModelFactoryTest::NestedModel.new.tap do |instance|
      instance.Name = nested_model_name
    end
  end
  let(:blank_instance) { ModelFactoryTest::TestModel.new }
  let(:instance) do
    ModelFactoryTest::TestModel.new.tap do |instance|
      instance.Name = name
      instance.A_flag = truth
      instance.someNumber = number
      instance.someOther_number = other_number
      instance.NestedModel = another_nested_model_instance
    end
  end
  let(:name) { 'Mx. Tape' }
  let(:truth) { true }
  let(:number) { 42 }
  let(:other_number) { 8_675_309 }
  let(:required_fields) { %w[Name NestedModel] }

  let(:json_model) do
    { 'definitions' =>
      { test_model_class.to_s =>
        { 'id' => test_model_class.to_s,
          'description' => '',
          'required' => required_fields,
          'extends' => '',
          'properties' => {
            'Name' => {
              'type' => 'string', 'description' => 'A name'
            },
            'A_flag' => {
              'type' => 'boolean', 'description' => 'A flag'
            },
            'someOther_number' => {
              'type' => 'integer', 'description' => 'any integer'
            },
            nested_model_class.to_s => {
              '$ref' => nested_model_class.to_s
            },
            'someNumber' => {
              'type' => 'number',
              'description' => 'A number from a list',
              'enum' => [
                1,
                2,
                7,
                42
              ]
            }
          } },
        nested_model_class.to_s =>
        { 'id' => nested_model_class.to_s,
          'description' => '',
          'extends' => '',
          'properties' => {
            'Name' => {
              'type' => 'string', 'description' => 'A name'
            }
          } } } }
  end

  before(:each) do
    described_class.send(:define_models, json_model)
  end

  after(:each) do
    # This is to prevent warnings caused by redefining constants.
    described_class.send(:remove_const, test_model_class) if described_class.constants.include?(test_model_class)
    described_class.send(:remove_const, nested_model_class) if described_class.constants.include?(nested_model_class)
  end

  context '.define_models' do
    it 'can load model classes from json' do
      expect(described_class.constants).to include(test_model_class)
    end

    it 'creates models with the correct dynamic methods' do
      expect(instance).to respond_to(:Name)
      expect(instance).to respond_to(:A_flag)
      expect(instance).to respond_to(:someNumber)
    end

    it 'returns nil if there is a problem' do
      expect(described_class.send(:define_models, nil)).to be_nil
    end
  end

  context '.define_models_from_json_string' do
    it 'returns nil if not given something to read' do
      expect(described_class.send(:define_models_from_json_string, nil)).to be_nil
    end

    it 'parses the string if given one' do
      string = 'foo'
      expect(JSON).to receive(:parse).with(string).and_return('some_json')
      allow(described_class).to receive(:define_models)
      expect(described_class.send(:define_models_from_json_string, string)).to be_nil
    end
  end
  context '.define_models_from_file' do
    it 'returns nil if not given something to read' do
      expect(described_class.send(:define_models_from_file, nil)).to be_nil
    end

    it 'reads the file if given one' do
      fake_file = 'foo'
      expect(File).to receive(:read).with(fake_file)
      expect(described_class.send(:define_models_from_file, fake_file)).to be_nil
    end
  end

  context '.to_json' do
    it 'returns the results of as_json, JSONized' do
      allow(instance).to receive(:as_json).and_return('foo')
      expect(instance.to_json).to eq('foo'.to_json)
    end
  end

  context '.valid?' do
    context 'with a valid model' do
      it 'returns true' do
        expect(instance).to be_valid
      end
    end
    context 'with an invalid model' do
      context 'with required attribute missing' do
        let(:name) { nil }
        it 'returns false' do
          expect(instance).not_to be_valid
        end
      end

      context 'with an attribute set to the wrong type' do
        let(:truth) { 'the square root of true' }
        it 'returns false' do
          expect(instance).not_to be_valid
        end
      end

      context 'with an enum attribute set to a non-allowed value' do
        let(:number) { 11_111 }
        it 'returns false' do
          expect(instance).not_to be_valid
        end
      end
    end
  end

  context '.as_json' do
    it 'returns a hash representation of the object' do
      expect(instance.as_json).to include(
        Name: name,
        A_flag: truth,
        someOther_number: other_number,
        someNumber: number,
        NestedModel: {
          Name: nested_model_name
        }
      )
    end

    it 'returns nil if the model is empty' do
      expect(nested_model_instance.as_json).to be_nil
    end
  end

  context 'validate' do
    let(:truth) { 'the square root of true' }
    let(:number) { 11_111 }
    let(:name) { nil }
    let(:generic_errors) do
      {
        'A_flag' => "Invalid parameter: Expected valid boolean, but was #{truth.inspect}",
        'someNumber' => "Invalid parameter: Expected one of [1, 2, 7, 42], but was #{number.inspect}"
      }
    end

    context 'With Name as a required field' do
      it 'gives helpful errors' do
        expect(instance.validate).to eq({
          'Name' => "Invalid parameter: Expected valid string, but was #{name.inspect}"
        }.merge(generic_errors))

        expect(blank_instance.validate).to eq(
          'Name' => 'Invalid parameter: Missing required parameter'
        )
      end
    end

    context 'Without Name as a required field' do
      let(:required_fields) { [] }

      it 'Does not include the name field type error even when nil' do
        expect(instance.validate).to eq(generic_errors)
      end
    end
  end
end
