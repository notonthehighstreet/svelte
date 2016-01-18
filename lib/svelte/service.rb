module Svelte
  # Represents a group of related endpoints on the API.
  class Service
    class << self
      # Static method to generate Service via URL or JSON.
      # @param [String] url: full URL of the Swagger API spec
      # @param [String] json: full Swagger API spec as a String
      # @param [String] module_name: constant name where Svelte will
      #   build the functionality on top of
      # @return [Svelte::Service::<name>] A Service object
      def create(url:, json:, module_name:, options:)
        json = get_json(url: url) if url
        SwaggerBuilder.new(raw_hash: JSON.parse(json),
                           module_name: module_name,
                           options: options).make_resource
      end

      private

      def get_json(url:)
        Faraday.get(url).body
      rescue Faraday::ClientError => e
        raise Svelte::HTTPError.new(
          message: "Could not get API json from #{url}",
          parent: e
        )
      end
    end
  end
end
