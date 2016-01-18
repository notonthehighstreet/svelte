module Svelte
  # Dynamically builds Swagger API operations on top of a given module
  class OperationBuilder
    # Builds an operation on top of `module_constant`
    # @param operation [Svete::Operation] operation to build
    # @param module_constant [Module] operation to build
    def self.build(operation:, module_constant:, configuration:)
      builder = self
      method_name = StringManipulator.method_name_for(operation.id)
      module_constant.define_singleton_method(method_name) do |*parameters|
        GenericOperation.call(
          verb: operation.verb,
          path: operation.path,
          configuration: configuration,
          parameters: builder.request_parameters(full_parameters: parameters),
          options: builder.options(full_parameters: parameters))
      end
    end

    def self.request_parameters(full_parameters:)
      return {} if full_parameters.empty?
      full_parameters.first.inject({}) do |memo, (k, v)|
        memo.merge!(k.to_s => v)
      end
    end

    def self.options(full_parameters:)
      full_parameters[1] || {}
    end
  end
end
