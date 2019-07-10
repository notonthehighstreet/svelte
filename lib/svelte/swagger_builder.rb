# frozen_string_literal: true

module Svelte
  # Dynamically builds Swagger API paths and operations on top of a given module
  class SwaggerBuilder
    attr_reader :raw_hash, :module_name, :configuration, :headers

    # Creates a new SwaggerBuilder
    # @param raw_hash [Hash] Swagger API definition
    # @param module_name [String] name of the constant you want built
    # @param options [Hash] Swagger API options. It will be used to build the
    #   [Configuration]. Supported values: ":host", ":base_path", ":protocol"
    # @param headers [Hash] REST client HTTP request headers
    def initialize(raw_hash:, module_name:, options:, headers:)
      @raw_hash = raw_hash
      @module_name = module_name
      @configuration = build_configuration(options, headers)
      @headers = headers
      validate
    end

    # Dynamically creates a new resource on top of `Svelte::Service` with the
    # name `module_name`, based on the Swagger API description provided
    # in `raw_hash`
    # @return [Module] the module built
    def make_resource
      resource = Module.new
      paths.each do |path|
        new_module = PathBuilder.build(path: path, module_constant: resource)
        path.operations.each do |operation|
          OperationBuilder.build(operation: operation,
                                 module_constant: new_module,
                                 configuration: configuration)
        end
      end
      Service.const_set(module_name, resource)
    end

    # @return [Array<Path>] Paths of the Swagger spec
    def paths
      raw_hash['paths'].map do |path, operations|
        Path.new(path: path, operations: operations)
      end
    end

    # @return [String] base path of the Swagger spec
    def base_path
      raw_hash['basePath']
    end

    # @return [String] host of the Swagger spec
    def host
      raw_hash['host']
    end

    private

    def build_configuration(_options, headers)
      options = {
        host: _options[:host] || host,
        base_path: _options[:base_path] || base_path,
        protocol: _options[:protocol],
        headers: headers || {}
      }
      Configuration.new(options: options)
    end

    def validate
      validate_version
      validate_paths
      validate_host
      validate_base_path
    end

    def validate_version
      raise VersionError if raw_hash['swagger'] != '2.0'
    end

    def validate_paths
      unless raw_hash['paths'].is_a?(Hash)
        raise JSONError, 'Expected JSON to contain an object of valid paths'
      end
    end

    def validate_host
      unless raw_hash['host'].is_a?(String)
        raise JSONError, '`host` field in JSON is invalid'
      end
    end

    def validate_base_path
      unless raw_hash['basePath'].is_a?(String)
        raise JSONError, '`basePath` field in JSON is invalid'
      end
    end
  end
end
