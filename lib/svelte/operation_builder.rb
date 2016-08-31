module Svelte
  # Dynamically builds Swagger API operations on top of a given module
  class OperationBuilder
    class << self
      # Builds an operation on top of `module_constant`
      # @param operation [Svete::Operation] operation to build
      # @param module_constant [Module] operation to build
      # @param configuration [Configuration] Swagger API configuration
      def build(operation:, module_constant:, configuration:)
        builder = self
        method_name = StringManipulator.method_name_for(operation.id)
        module_constant.define_singleton_method(method_name) do |*parameters|
          GenericOperation.call(
            verb: operation.verb,
            path: operation.path,
            configuration: configuration,
            parameters: builder.request_parameters(full_parameters: parameters),
            options: builder.options(full_parameters: parameters, middleware_stack: configuration.middleware_stack))
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
      def options(full_parameters:, middleware_stack:)
        options = full_parameters[1] || {}
        options[:middleware_stack] ||= middleware_stack
        options
      end
    end
  end
end
