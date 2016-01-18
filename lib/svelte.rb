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
# You can hand it a spec which defines an API resource called 'Comments',
# with an endpoint at `/api/comments/{id}` that supports GET,
# POST and DELETE methods,
# and Svelte will hand you a `Svelte::Service::Comments` object that can be used
# like so:
#
# @example
#   Svelte::Service::Comments.comments_get({ "id" => 10 })
#   Svelte::Service::Comments.comments_post({ "id" => 10 })
#   Svelte::Service::Comments.comments_delete({ "id" => 10 })
module Svelte
  # @param [String] url: url pointing to a Swagger spec
  # @param [String] json: the entire Swagger spec as a String
  # @param [String] module_name: constant name where you want Svelte to build
  #   the new functionality on top of
  def self.create(url: nil, json: nil, module_name:, options: {})
    Service.create(url: url, json: json, module_name: module_name, options: options)
  end
end
