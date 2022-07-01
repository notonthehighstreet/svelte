# frozen_string_literal: true

require 'base64'

module Svelte
  # Pass authentication from headers object
  module HeadersBuilder
    def build_headers(options:)
      headers = options[:headers].is_a?(Hash) ? options[:headers].clone : {}

      if options[:auth]
        basic = options[:auth][:basic]
        token = options[:auth][:token]

        if basic
          credentials = Base64.encode64([
            basic[:username],
            basic[:password]
          ].join(':')).chomp

          headers['Authorization'] = "Basic #{credentials}"
        elsif token
          headers['Authorization'] = token
        end
      end

      headers
    end
  end
end
