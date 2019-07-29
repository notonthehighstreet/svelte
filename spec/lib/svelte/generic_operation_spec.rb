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
  let(:options) { {} }
  let(:protocol) { 'http' }
  let(:headers) { nil }
  let(:request_headers) { {} }
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
                                                            headers: request_headers)
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
                                                            headers: request_headers)
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
                                                          headers: request_headers)
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

    context 'with headers specified in options' do
      let(:options) { { headers: { test: 'value' } } }
      let(:request_headers) { { test: 'value' } }
      let(:url) { 'http://localhost/pet' }
      let(:parameter_elements) { [] }
      let(:params) { {} }
      let(:url_path) { '/pet' }

      it 'passes headers to Faraday' do
        expect(Svelte::RestClient).to receive(:call).with(verb: verb,
                                                          url: url,
                                                          params: params,
                                                          headers: request_headers,
                                                          options: options)

        described_class.call(verb: verb,
                            path: path,
                            configuration: configuration,
                            parameters: parameters,
                            headers: headers,
                            options: options)
      end

      context 'with headers specified in request' do
        let(:headers) { { test: 'value' } }
        let(:request_headers) { { test: 'value' } }
        let(:url) { 'http://localhost/pet' }
        let(:parameter_elements) { [] }
        let(:params) { {} }
        let(:url_path) { '/pet' }

        it 'passes headers to Faraday' do
          expect(Svelte::RestClient).to receive(:call).with(verb: verb,
                                                            url: url,
                                                            params: params,
                                                            headers: request_headers,
                                                            options: options)

          described_class.call(verb: verb,
                              path: path,
                              configuration: configuration,
                              parameters: parameters,
                              headers: headers,
                              options: options)
        end
      end

      context 'with headers specified in options and overridden in request' do
        let(:options) { { headers: { test: 'value1' } } }
        let(:headers) { { test: 'value2' } }
        let(:request_headers) { { test: 'value2' } }
        let(:url) { 'http://localhost/pet' }
        let(:parameter_elements) { [] }
        let(:params) { {} }
        let(:url_path) { '/pet' }

        it 'passes headers to Faraday' do
          expect(Svelte::RestClient).to receive(:call).with(verb: verb,
                                                            url: url,
                                                            params: params,
                                                            headers: request_headers,
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
  end
end
