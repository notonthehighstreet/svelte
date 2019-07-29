# frozen_string_literal: true

require 'spec_helper'

describe Svelte::GenericOperation do
  let(:verb) { :get }
  let(:path) do
    double(:path,
           path: url_path,
           parameter_elements: parameter_elements)
  end
  let(:base_path) { '/' }
  let(:host) { 'localhost' }
  let(:parameters) { {} }
  let(:options) { { headers: { test: 'value' } } }
  let(:protocol) { 'http' }
  let(:headers) { { test: 'value' } }
  let(:configuration) do
    double(:configuration,
           host: host,
           base_path: base_path,
           protocol: protocol,
           headers: headers)
  end

  context '#call' do
    context 'with url parameter' do
      context 'at the end of the url' do
        let(:url_path) { '/pet/{petId}' }
        let(:parameter_elements) { ['petId'] }
        let(:params) { {} }

        let(:parameters) do
          {
            'petId' => pet_id
          }
        end
        let(:pet_id) { 1 }
        let(:url) { "http://localhost/pet/#{pet_id}" }

        it 'calls Svelte::RestClient with the correct parameters' do
          expect(Svelte::RestClient).to receive(:call).with(verb: verb,
                                                            url: url,
                                                            params: params,
                                                            options: options,
                                                            headers: nil)
          described_class.call(verb: verb,
                               path: path,
                               configuration: configuration,
                               parameters: parameters,
                               options: options)
        end
      end

      context 'not at the end of the url' do
        let(:url_path) { '/pet/{petId}/hobbies' }
        let(:parameter_elements) { ['petId'] }
        let(:params) { {} }

        let(:parameters) do
          {
            'petId' => pet_id
          }
        end
        let(:pet_id) { 1 }
        let(:url) { "http://localhost/pet/#{pet_id}/hobbies" }

        it 'calls Svelte::RestClient with the correct parameters' do
          expect(Svelte::RestClient).to receive(:call).with(verb: verb,
                                                            url: url,
                                                            params: params,
                                                            options: options,
                                                            headers: nil)
          described_class.call(verb: verb,
                               path: path,
                               configuration: configuration,
                               parameters: parameters,
                               options: options)
        end
      end
    end

    context 'without url parameters' do
      let(:url_path) { '/pet' }
      let(:parameter_elements) { [] }
      let(:params) { parameters }
      let(:parameters) do
        {
          'petId' => pet_id
        }
      end
      let(:pet_id) { 1 }
      let(:url) { 'http://localhost/pet' }

      it 'calls Svelte::RestClient with the correct parameters' do
        expect(Svelte::RestClient).to receive(:call).with(verb: verb,
                                                          url: url,
                                                          params: params,
                                                          options: options,
                                                          headers: nil)
        described_class.call(verb: verb,
                             path: path,
                             configuration: configuration,
                             parameters: parameters,
                             options: options)
      end
    end

    context 'with missing url parameters' do
      let(:url_path) { '/pet/{petId}' }
      let(:parameter_elements) { ['petId'] }

      it 'raises a Svelte::ParameterError exception' do
        expect do
          described_class.call(verb: verb,
                               path: path,
                               configuration: configuration,
                               parameters: parameters,
                               options: options,
                               headers: nil)
        end
          .to raise_error(Svelte::ParameterError,
                          'Required parameter `petId` missing')
      end
    end
  end

  context 'with headers' do
    let(:headers) { {'authorization' => 'foo'} }
    let(:url) { 'http://localhost/pet' }
    let(:parameter_elements) { [] }
    let(:params) { parameters }
    let(:parameters) do
      {
        'foo' => 'bar'
      }
    end
    let(:url_path) { '/pet' }

    it 'passes headers to Faraday' do
      expect(Svelte::RestClient).to receive(:call).with(verb: verb,
                                                        url: url,
                                                        params: params,
                                                        headers: headers,
                                                        options: options)
        described_class.call(verb: verb,
                             path: path,
                             configuration: configuration,
                             parameters: parameters,
                             headers: headers,
                             options: options)
    end
  end
end
