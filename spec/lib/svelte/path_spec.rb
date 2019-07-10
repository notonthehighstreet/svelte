# frozen_string_literal: true

require 'spec_helper'

describe Svelte::Path do
  let(:json) { JSON.parse(File.read('spec/fixtures/petstore.json')) }
  let(:path_operations) { json['paths'][path_key] }
  let(:path) do
    described_class.new(path: path_key, operations: path_operations)
  end

  context 'paths with no url parameters' do
    let(:path_key) { '/store/inventory' }

    it 'has the correct non parameter elements' do
      expect(path.non_parameter_elements).to match_array(%w[store inventory])
    end

    it 'has the correct parameter elements' do
      expect(path.parameter_elements).to match_array([])
    end

    context '#operations' do
      it 'returns an array of operations' do
        expect(path.operations).to be_an(Array)
      end

      it 'the array has the correct size' do
        expect(path.operations.size).to eq(1)
      end

      it 'the array has the correct operations' do
        expect(path.operations.map(&:id)).to match_array(['getInventory'])
      end
    end
  end

  context 'paths with url parameters' do
    let(:path_key) { '/store/order/{orderId}' }

    it 'has the correct non parameter elements' do
      expect(path.non_parameter_elements).to match_array(%w[store order])
    end

    it 'has the correct parameter elements' do
      expect(path.parameter_elements).to match_array(['orderId'])
    end

    context '#operations' do
      it 'returns an array of operations' do
        expect(path.operations).to be_an(Array)
      end

      it 'the array has the correct size' do
        expect(path.operations.size).to eq(2)
      end

      it 'the array has the correct operations' do
        expect(path.operations.map(&:id))
          .to match_array(%w[getOrderById deleteOrder])
      end
    end
  end
end
