# frozen_string_literal: true

module Svelte
  # Svelte error class to represent version errors.
  # Raised when a Swagger v1 JSON is fed into Svelte
  class VersionError < StandardError
    def message
      'Invalid Swagger version spec supplied. Svelte supports Swagger v2 only'
    end
  end
end
