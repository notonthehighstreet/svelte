module Svelte
  # Dynamically builds a module hierarchy on top of a given module
  # based on the given Path
  class PathBuilder
    class << self
      # Builds a new Module hierarchy on top of `module_constant`
      # If the path contains more than one part, modules will be built
      # on top of each other.
      #
      # Example:
      # If the `path` is `/store/inventory` and the `module_constant` is
      # `Test`, the resulting module hierarchy will be `Test::Store::Inventory`
      # @param path [Svelte::Path] path to build
      # @param module_constant [Module] operation to build
      def build(path:, module_constant:)
        create_module_hierarchy(base_module: module_constant,
                                additional_modules: path.non_parameter_elements)
      end

      private

      def create_module_hierarchy(base_module:, additional_modules:)
        additional_modules.reduce(base_module) do |current_module, element|
          constant_name = StringManipulator.constant_name_for(element)

          unless current_module.const_defined?(constant_name, false)
            current_module.const_set(constant_name, Module.new)
          end

          current_module.const_get(constant_name, false)
        end
      end
    end
  end
end
