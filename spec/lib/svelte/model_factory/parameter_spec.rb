require 'spec_helper'

require 'svelte/model_factory/parameter'

describe Svelte::ModelFactory::Parameter do
  subject { described_class.new(type) }
  let(:type) { 'type' }

  context 'unset' do
    it 'appears as unset' do
      expect(subject.value.inspect).to eq('unset')
    end
  end

  context '#valid?' do
    it 'is true when there are no messages' do
      allow(subject).to receive(:validate).and_return('')
      expect(subject).to be_valid
    end

    it 'is false when there are messages' do
      allow(subject).to receive(:validate).and_return('AN ERROR')
      expect(subject).not_to be_valid
    end
  end

  it 'is not present when unset' do
    expect(subject).not_to be_present
  end

  it 'is present when set' do
    subject.value = 'foo'
    expect(subject).to be_present
  end

  context '#as_json' do
    it 'returns nil if unset' do
      expect(subject.as_json).to be_nil
    end

    it 'returns value if set' do
      value = 'json'
      subject.value = value
      expect(subject.as_json).to be(value)
    end
  end

  context 'validation' do
    before(:each) do
      subject.value = value
    end

    context 'validating a boolean' do
      let(:type) { 'boolean' }
      context 'when value is not a boolean' do
        let(:value) { 'NOT A BOOLEAN' }
        it 'returns a message' do
          expect(subject.validate).to eq("Invalid parameter: Expected valid boolean, but was #{value.inspect}")
        end
      end

      context 'when value is a boolean' do
        let(:value) { true }
        it 'returns no message' do
          expect(subject.validate).to eq('')
        end
      end
    end

    context 'validating a string' do
      let(:type) { 'string' }
      context 'when value is not a string' do
        let(:value) { 1_234_567_890 }
        it 'returns a message' do
          expect(subject.validate).to eq("Invalid parameter: Expected valid string, but was #{value.inspect}")
        end
      end

      context 'when value is a string' do
        let(:value) { 'STRING' }
        it 'returns no message' do
          expect(subject.validate).to eq('')
        end
      end
    end

    context 'validating a string' do
      let(:value) { { key: :value } }
      let(:type) { 'object' }
      it 'returns no message' do
        expect(subject.validate).to eq('')
      end
    end

    context 'validating a number' do
      let(:type) { 'number' }
      context 'when value is not a number' do
        let(:value) { true }
        it 'returns a message' do
          expect(subject.validate).to eq("Invalid parameter: Expected valid number, but was #{value.inspect}")
        end
      end

      context 'when value is a number' do
        let(:value) { 1_234_567_890 }
        it 'returns no message' do
          expect(subject.validate).to eq('')
        end
      end
    end

    context 'validating an integer' do
      let(:type) { 'integer' }
      context 'when value is not an integer' do
        let(:value) { true }
        it 'returns a message' do
          expect(subject.validate).to eq("Invalid parameter: Expected valid integer, but was #{value.inspect}")
        end
      end

      context 'when value is an integer' do
        let(:value) { 1234567890 }
        it 'returns no message' do
          expect(subject.validate).to eq('')
        end
      end
    end

    context 'validating an array' do
      let(:type) { 'array' }
      context 'when value is not an array' do
        let(:value) { true }
        it 'returns a message' do
          expect(subject.validate).to eq("Invalid parameter: Expected valid array, but was #{value.inspect}")
        end
      end

      context 'when value is an array' do
        let(:value) { [1, 2, 3] }
        it 'returns no message' do
          expect(subject.validate).to eq('')
        end

        context 'with validatable types' do
          context 'that are valid' do
            let(:valid_double) { double(:parameter, valid?: true) }
            let(:value) { [valid_double] }
            it 'does not return any errors' do
              expect(subject.validate).to eq('')
            end
          end

          context 'that are invalid' do
            let(:valid_double) { double(:parameter, valid?: false) }
            let(:value) { [valid_double] }
            it 'returns the correct error' do
              expect(subject.validate).to eq("Invalid parameter: Expected valid array, but was #{value.inspect}")
            end
          end
        end
      end
    end

    context 'an invalid type' do
      let(:type) { 'foo' }
      let(:value) { 'unimportant' }
      it 'returns a message' do
        expect(subject.validate).to eq("Invalid parameter: Expected valid foo, but was #{value.inspect}")
      end
    end

    context 'with permitted values' do
      subject { described_class.new(type, permitted_values: permitted_values) }
      let(:type) { 'integer' }
      let(:value) { 42 }
      let(:other_value) { 49 }

      before(:each) do
        subject.value = value
      end

      context 'when the value is allowed' do
        let(:permitted_values) { [value] }

        it 'returns no message' do
          expect(subject.validate).to eq('')
        end
      end

      context 'when the value is not allowed' do
        let(:permitted_values) { [other_value] }

        it 'returns a message' do
          expect(subject.validate).to eq("Invalid parameter: Expected one of #{permitted_values}, but was #{value}")
        end
      end
    end
  end
end
