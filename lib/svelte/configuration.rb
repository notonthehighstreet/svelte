module Svelte
  # Holds miscelanious configuration options for the current
  # Swagger API specification
  class Configuration
    attr_reader :host, :base_path, :protocol, :middleware_stack
    # Creates a new Configuration instance
    # @param options [Hash] configuration options
    def initialize(options:)
      @host       = options[:host]
      @base_path  = options[:base_path]
      @middleware_stack = options[:middleware_stack] || []
      @protocol   = options[:protocol] || default_protocol
    end

    private

    def default_protocol
      'http'
    end
  end
end
