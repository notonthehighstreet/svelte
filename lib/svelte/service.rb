require 'base64'

module Svelte
  # Dynamically generates a client to consume a Swagger API
  class Service
    class << self
      # Generate a Service via URL or JSON.
      # @param url [String] full URL of the Swagger API spec
      # @param json [String] full Swagger API spec as a String
      # @param module_name [String] constant name where Svelte will
      #   build the functionality on top of
      # @param options [Hash] options passed as configuration to the 
      #   generated Swagger objects.  :auth options will also be
      #   used here when making the initial Swagger spec request.
      # @return [Module] A newly created `Module` with the
      #   module hierarchy and methods to consume the Swagger API
      #   The new module will be built on top of `Svelte::Service` and will
      #   have `module_name` as its constant name, therefore it can also be
      #   accessed via `Svelte::Service::<module_name>`. For example, if
      #   `module_name` is `Comments`, the new module will be built in
      #   `Svelte::Service::Comments`
      # @note Either `url` or `json` need to be provided. `url` will take
      #   precedence over `json`
      def create(url: nil, json: nil, module_name:, options: {})
        options_with_auth = configure_auth_options(options: options)
        json = get_json(url: url, options: options_with_auth) if url

        SwaggerBuilder.new(raw_hash: JSON.parse(json.to_s),
                           module_name: module_name,
                           options: options_with_auth).make_resource
      end

      private

      def get_json(url:, options:)
        create_connection(url: url, options: options).get.body
      rescue Faraday::ClientError => e
        raise HTTPError.new(
          message: "Could not get API json from #{url}",
          parent: e
        )
      end

      def configure_auth_options(options:)
        options[:headers] ||= {}

        auth = options.delete(:auth)

        if auth
          basic = auth.delete(:basic)
          token = auth.delete(:token)
          
          if basic
            token = Base64.encode64([
              basic[:username], 
              basic[:password]
            ].join(':')).chomp
            
            options[:headers]["Authorization"] = "Basic #{token}"
          elsif token
            options[:headers]["Authorization"] = token
          end
        end

        options
      end

      def create_connection(url:, options:)
        connection = Faraday.new(url: url)
        options[:headers].each { |key, value| connection.headers[key] = value }
        connection
      end
    end
  end
end
