# frozen_string_literal: true

module Svelte
  # Class that handles the actual execution of dynamically generated operations
  # Each created operation will eventually call this class in order to make the
  # final HTTP request to the REST endpoint
  class GenericOperation
    class << self
      # Make an HTTP request to a REST resource
      # @param verb [String] http verb to use, i.e. `'get'`
      # @param path [Path] Path object containing information about the
      #   operation to be called
      # @param configuration [Configuration] Swagger API configuration
      # @param parameters [Hash] payload of the request, i.e. `{ petId: 1}`
      # @param options [Hash] request options, i.e. `{ timeout: 10 }`
      def call(verb:, path:, configuration:, parameters:, options:, headers: nil)
        url = url_for(configuration: configuration,
                      path: path,
                      parameters: parameters)
        request_parameters = clean_parameters(path: path,
                                              parameters: parameters)
        request_options = build_request_options(configuration: configuration,
                                                options: options)
        RestClient.call(verb: verb,
                        url: url,
                        params: request_parameters,
                        options: options,
                        headers: headers,
                        options: request_options)
      end

      private

      def url_for(configuration:, path:, parameters:)
        url_path = url_path(path: path, parameters: parameters)
        protocol = configuration.protocol
        host = configuration.host
        base_path = configuration.base_path
        base_path = '' if base_path == '/'
        "#{protocol}://#{host}#{base_path}#{url_path}"
      end

      def url_path(path:, parameters:)
        url_path = path.path.dup
        path.parameter_elements.each do |parameter_element|
          if parameters.key?(parameter_element)
            url_path.sub!("{#{parameter_element}}", parameters[parameter_element].to_s)
          else
            raise ParameterError, "Required parameter `#{parameter_element}` missing"
          end
        end
        url_path
      end

      def clean_parameters(path:, parameters:)
        clean_parameters = parameters.dup
        path.parameter_elements.each do |parameter_element|
          clean_parameters.delete(parameter_element)
        end
        clean_parameters
      end

      def build_request_options(configuration:, options:)
        if configuration.headers&.any?
          return (options || {}).merge(headers: configuration.headers)
        end

        options
      end
    end
  end
end
