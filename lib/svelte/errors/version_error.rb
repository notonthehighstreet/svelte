module Svelte
  # Svelte error class to represent version errors.
  # Raised when a Swagger v1 JSON is fed into Svelte
  class VersionError < StandardError

    def initialize(supplied_version)
      @supplied_version = supplied_version
    end

    def message
      %-"swagger" field is #{@supplied_version or 'empty'}. Svelte only supports Swagger v2.0.-
    end

  end
end
