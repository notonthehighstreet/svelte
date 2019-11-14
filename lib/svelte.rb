# frozen_string_literal: true

require 'json'
require 'svelte/version'
require 'svelte/string_manipulator'
require 'svelte/configuration'
require 'svelte/errors'
require 'svelte/model_factory'
require 'svelte/rest_client'
require 'svelte/headers_builder'
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
  # @param url [String] url pointing to a Swagger spec
  # @param json [String] the entire Swagger spec as a String
  # @param module_name [String] constant name where you want Svelte to build
  #   the new functionality on top of
  # @param options [Hash] configuration options when making HTTP requests
  #   Supported values are:
  #     :auth [Hash] either { token: "value" } or { basic: { username: "value", password: "value" }}
  #     :headers [Hash] HTTP request headers
  #     :host [String] overrides the "host" value in the Swagger spec
  #     :base_path [String] overrides the "basePath" value in the Swagger spec
  #     :protocol [String] overrides the network protocol used (defaults to "http")
  # @note Either `url` or `json` need to be provided. `url` will take
  #   precedence over `json`
  def self.create(url: nil, json: nil, module_name:, options: {})
    Service.create(url: url, json: json, module_name: module_name, options: options)
  end
end
