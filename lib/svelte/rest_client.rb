require 'faraday'
require 'faraday_middleware'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

module Svelte
  # Rest client to make requests to the service endpoints
  class RestClient
    class << self

      # Makes an http call to a given REST endpoint
      # @param verb [String] http verb to use for the request
      #   (`get`, `post`, `put`, etc.)
      # @param url [String] request url
      # @param params [Hash] parameters to send to the request
      # @param options [Hash] options
      # @raise [HTTPError] if an HTTP layer error occurs,
      #   an exception will be raised
      #
      # @return [Faraday::Response] http response from the service
      def call(verb:, url:, params: {}, options: {})
        middleware_stack = options[:middleware_stack]
        connection = connection_with(middleware_stack: middleware_stack)

        connection.send verb, url, params do |request|
          request.options.timeout = options[:timeout] if options[:timeout]
        end
      rescue *rescuable => e
        raise HTTPError.new(parent: e)
      end

      private

      def rescuable
        [Faraday::TimeoutError, Faraday::ResourceNotFound, Faraday::ClientError]
      end

      def connection_with(middleware_stack:)
        connections[middleware_stack] ||= new_connection(middleware_stack)
      end

      def new_connection(middleware_stack)
        Faraday.new(ssl: { verify: true }) do |faraday|
          faraday.request :json

          Array(middleware_stack).each do |middleware, options|
            faraday.use middleware, options
          end

          faraday.response :json, content_type: /\bjson$/
          faraday.adapter :typhoeus
        end
      end

      def connections
        @connections ||= {}
      end
    end
  end
end
