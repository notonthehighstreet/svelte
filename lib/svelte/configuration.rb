module Svelte
  # Holds miscelanious configuration options for the current
  # Swagger API specification
  class Configuration
    attr_reader :host, :base_path, :protocol, :headers
    # Creates a new Configuration instance
    # @param options [Hash] configuration options
    def initialize(options:)
      @host = options[:host]
      @base_path = options[:base_path]
      @protocol = options[:protocol] || default_protocol
      @headers = options[:headers]
    end

    private

    def default_protocol
      'http'
    end
  end
end
