# frozen_string_literal: true

module Svelte
  # Svelte error class to represent parameter errors. For example
  # when a request is made and some required parameters are missing
  class ParameterError < StandardError; end
end
