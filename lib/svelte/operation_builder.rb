# frozen_string_literal: true

module Svelte
  # Dynamically builds Swagger API operations on top of a given module
  class OperationBuilder
    include HeadersBuilder
    class << self
      # Builds an operation on top of `module_constant`
      # @param operation [Svete::Operation] operation to build
      # @param module_constant [Module] operation to build
      # @param configuration [Configuration] Swagger API configuration
      def build(operation:, module_constant:, configuration:)
        builder = self
        builder.extend(HeadersBuilder)
        method_name = StringManipulator.method_name_for(operation.id)
        module_constant.define_singleton_method(method_name) do |*parameters|
          options = builder.options(full_parameters: parameters)
          request_parameters = builder.request_parameters(full_parameters: parameters)
          headers = builder.strip_headers!(
            operation_parameters: operation.properties["parameters"],
            request_parameters: request_parameters)

          headers = builder.build_headers(options: options).merge(headers)

          GenericOperation.call(
            verb: operation.verb,
            path: operation.path,
            configuration: configuration,
            headers: headers,
            parameters: request_parameters,
            options: options
          )
        end
      end

      # Returns the parameters that are to be sent as part of the request
      # to the API endpoint.
      # @param full_parameters [Array] array with the arguments passed into the
      #   method call
      # @return [Hash] Hash with all the parameters to be sent as part of the
      #   request
      # @note All keys will be transformed from `Symbol` to `String`
      def request_parameters(full_parameters:)
        return {} if full_parameters.compact.empty?

        full_parameters.first.inject({}) do |memo, (k, v)|
          memo.merge!(k.to_s => v)
        end
      end

      # Returns the options that are to be sent as part of the request
      # to the API endpoint.
      # @param full_parameters [Array] array with the arguments passed into the
      #   method call
      # @return [Hash] Hash with all the options to be sent as part of the
      #   request
      def options(full_parameters:)
        full_parameters[1] || {}
      end

      # Strips headers from parameters and returns them.
      # @param operation_parameters [Array] The parameters defined by the operation
      # @param request_parameters [Hash] The parameters given by the caller
      # @return [Hash] The headers for GenericOperation to build the request
      def strip_headers!(operation_parameters:, request_parameters:)
        header_names = operation_parameters.reduce([]) do |memo, param|
          memo.push(param["name"].downcase) if param["in"] == 'header'
          memo
        end

        headers = request_parameters.select { |key, val| header_names.include?(key)}
        request_parameters.reject! { |key, val| header_names.include?(key) }
        headers.empty? ? {} : headers
      end
    end
  end
end
