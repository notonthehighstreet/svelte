# frozen_string_literal: true

require 'spec_helper'

describe Svelte::RestClient do
  let(:test_url) { 'http://example.com/' }
  let(:verb) { :get }
  let(:error_message) { 'This is an error message' }

  it 'should return an http response' do
    stub_request(verb, test_url)
      .to_return(status: 404, body: '', headers: {})

    expect(described_class.call(verb: verb, url: test_url))
      .to be_an_instance_of(Faraday::Response)
  end

  context 'when the remote service is very slow' do
    before do
      stub_request(verb, test_url)
        .to_raise(Faraday::TimeoutError.new(error_message))
    end

    it 'returns a svelte error to indicate a timeout' do
      expect { described_class.call(verb: verb, url: test_url) }
        .to raise_error(Svelte::HTTPError, error_message)
    end
  end

  context 'when the remote service is not responding' do
    before do
      stub_request(verb, test_url)
        .to_raise(Faraday::ConnectionFailed.new(error_message))
    end

    it 'returns a svelte error to indicate an http error' do
      expect { described_class.call(verb: verb, url: test_url) }
        .to raise_error(Svelte::HTTPError, error_message)
    end
  end

  context 'when the resource is not found' do
    before do
      stub_request(verb, test_url)
        .to_raise(Faraday::ResourceNotFound.new(error_message))
    end

    it 'returns a svelte error to indicate a timeout' do
      expect { described_class.call(verb: verb, url: test_url) }
        .to raise_error(Svelte::HTTPError, error_message)
    end
  end

  context 'when passing a timeout option' do
    let(:options) { { timeout: timeout } }
    let(:timeout) { 5 }

    it 'sets up a timeout option on the request' do
      stub_request(verb, test_url)
        .to_return(status: 404, body: '', headers: {})

      expect(described_class.call(verb: verb,
                                  url: test_url,
                                  options: options)
        .env.request.timeout)
        .to eq(timeout)
    end
  end
end
