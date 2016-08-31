require 'json'
require 'svelte/version'
require 'svelte/string_manipulator'
require 'svelte/configuration'
require 'svelte/errors'
require 'svelte/model_factory'
require 'svelte/rest_client'
require 'svelte/service'
require 'svelte/swagger_builder'
require 'svelte/path'
require 'svelte/operation'
require 'svelte/path_builder'
require 'svelte/operation_builder'
require 'svelte/generic_operation'

# Svelte is a sleek Ruby API Client generated from a Swagger spec.
#
# You can hand it a spec which defines an path like `/api/comments/{id}` that
# supports a series of operations like `get`, `post`, `delete`, and a module
# name you want built (i.e. `Comments`), and it will hand you a
# `Svelte::Service::Comments` object that can be used like so:
#
# @example
#   Svelte::Service::Comments::Api::Comments.get_comment_by_id(id: 10)
#   Svelte::Service::Comments::Api::Comments.create_comment(contents: 'nice post!')
#   Svelte::Service::Comments::Api::Comments.delete_comment_by_id(id: 10)
module Svelte
  class<< self
    # @param url [String] url pointing to a Swagger spec
    # @param json [String] the entire Swagger spec as a String
    # @param module_name [String] constant name where you want Svelte to build
    #   the new functionality on top of
    # @note Either `url` or `json` need to be provided. `url` will take
    #   precedence over `json`
    def create(url: nil, json: nil, module_name:, options: {})
      check_args!(url: url, json: json)
      
      Service.create(url: url, json: json, module_name: module_name, options: options)
    end

    def check_args!(url:, json:)
      raise ArgumentError, "Must provide a URL or JSON argument" unless url || json
      URI.parse url if url
      JSON.parse json if json
    end
  end
end
