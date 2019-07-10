# frozen_string_literal: true

module Svelte
  # Describes a Swagger API Operation
  class Operation
    attr_reader :verb, :properties, :path

    # Creates a new Operation.
    # @param verb [String] operation verb i.e. `'get'`
    # @param properties [Hash] definition
    # @param path [Path] Path the operation belongs to
    def initialize(verb:, properties:, path:)
      @verb = verb
      @properties = properties
      @path = path
      validate
    end

    # Operation identifier
    # @return [String] unique Swagger API operation identifier
    def id
      properties['operationId']
    end

    private

    def validate
      unless id.is_a?(String)
        raise JSONError, 'Operation is missing mandatory `operationId` field'
      end
    end
  end
end
