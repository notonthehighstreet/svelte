require 'spec_helper'

describe Svelte::GenericOperation do
  let(:verb) { :get }
  let(:path) do
    double(:path,
           parameter_elements: parameter_elements,
           non_parameter_elements: non_parameter_elements)
  end
  let(:base_path) { '/' }
  let(:host) { 'localhost' }
  let(:parameters) { {} }
  let(:options) { {} }
  let(:protocol) { 'http' }
  let(:configuration) do
    double(:configuration,
           host: host,
           base_path: base_path,
           protocol: protocol)
  end

  context '#call' do
    context 'with url parameters' do
      let(:parameter_elements) { ['petId'] }
      let(:non_parameter_elements) { ['pet'] }
      let(:params) { {} }

      let(:parameters) do
        {
          'petId' => pet_id
        }
      end
      let(:pet_id) { 1 }
      let(:url) { "#{protocol}://#{host}#{base_path}pet/#{pet_id}" }

      it 'calls Svelte::RestClient with the correct parameters' do
        expect(Svelte::RestClient).to receive(:call).with(verb: verb,
                                                          url: url,
                                                          params: params,
                                                          options: options)
        described_class.call(verb: verb,
                             path: path,
                             configuration: configuration,
                             parameters: parameters,
                             options: options)
      end
    end

    context 'without url parameters' do
      let(:parameter_elements) { [] }
      let(:non_parameter_elements) { ['pet'] }
      let(:params) { parameters }
      let(:parameters) do
        {
          'petId' => pet_id
        }
      end
      let(:pet_id) { 1 }
      let(:url) { "#{protocol}://#{host}#{base_path}pet" }

      it 'calls Svelte::RestClient with the correct parameters' do
        expect(Svelte::RestClient).to receive(:call).with(verb: verb,
                                                          url: url,
                                                          params: params,
                                                          options: options)
        described_class.call(verb: verb,
                             path: path,
                             configuration: configuration,
                             parameters: parameters,
                             options: options)
      end
    end

    context 'with missing url parameters' do
      let(:parameter_elements) { ['petId'] }
      let(:non_parameter_elements) { ['pet'] }

      it 'raises a Svelte::ParameterError exception' do
        expect do
          described_class.call(verb: verb,
                               path: path,
                               configuration: configuration,
                               parameters: parameters,
                               options: options)
        end
          .to raise_error(Svelte::ParameterError,
                          'Required parameter `petId` missing')
      end
    end
  end
end
