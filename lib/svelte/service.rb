module Svelte
  # Dynamically generates a client to consume a Swagger API
  class Service
    class << self
      # Generate a Service via URL or JSON.
      # @param url [String] full URL of the Swagger API spec
      # @param json [String] full Swagger API spec as a String
      # @param module_name [String] constant name where Svelte will
      #   build the functionality on top of
      # @return [Module] A newly created `Module` with the
      #   module hierarchy and methods to consume the Swagger API
      #   The new module will be built on top of `Svelte::Service` and will
      #   have `module_name` as its constant name, therefore it can also be
      #   accessed via `Svelte::Service::<module_name>`. For example, if
      #   `module_name` is `Comments`, the new module will be built in
      #   `Svelte::Service::Comments`
      # @note Either `url` or `json` need to be provided. `url` will take
      #   precedence over `json`
      def create(url:, json:, module_name:, options:)
        json = get_json(url: url) if url
        SwaggerBuilder.new(raw_hash: JSON.parse(json.to_s),
                           module_name: module_name,
                           options: options).make_resource
      end

      private

      def get_json(url:)
        Faraday.get(url).body
      rescue Faraday::ClientError => e
        raise HTTPError.new(
          message: "Could not get API json from #{url}",
          parent: e
        )
      end
    end
  end
end
