module Svelte
  # Describes a Swagger API Path
  class Path
    attr_reader :non_parameter_elements, :parameter_elements

    # Creates a new Path.
    # @param path [String] path i.e. `'/store/inventory'`
    # @param operations [Hash] path operations
    def initialize(path:, operations:)
      @path = path
      separate_path_elements
      @raw_operations = operations
    end

    # Path operations
    # @return [Array<Svelte::Operation>] list of operations for the path
    def operations
      validate_operations
      @operations ||= @raw_operations.map do |operation, properties|
        Operation.new(verb: operation, properties: properties, path: self)
      end
    end

    private

    def separate_path_elements
      path_elements = @path.split('/').reject(&:empty?)
      @non_parameter_elements,
      @parameter_elements = path_elements.partition do |element|
        !element.match(/\{\w+\}/)
      end
      @parameter_elements.map! { |p| p.scan(/{(\w*)}/) }.flatten!
    end

    def validate_operations
      unless @raw_operations.is_a?(Hash)
        raise JSONError, "Expected the path to contain a list of operations"
      end
    end
  end
end
