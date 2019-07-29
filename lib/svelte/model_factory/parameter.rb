# frozen_string_literal: true

module Svelte
  module ModelFactory
    # Helper class to wrap around all parameters
    class Parameter
      # Constant to represent an unset parameter
      UNSET = Class.new

      # Override of the `inspect` method to return a string representation
      # of the class
      def UNSET.inspect
        'unset'
      end

      attr_reader :type
      attr_accessor :value

      # Creates a new Parameter
      # @param type [String]: Type of the parameter, i.e. `'integer'`
      # @param permitted_values [Array]: array of allowed values
      #  for the parameter
      # @param required [Boolean]: is the parameter required?
      def initialize(type, permitted_values: [], required: false)
        @type = type
        @permitted_values = permitted_values
        @required = required
        @value = UNSET
      end

      # @return [Boolean] true if and only if the parameter is valid
      def valid?
        validate.empty?
      end

      # @return [String] String representing
      #   the validation errors of the parameter
      def validate
        # We are not a required parameter, so being unset is fine.
        return '' if validate_blank

        # if we have a nested model
        return value.validate if value.respond_to?(:validate)

        messages = validate_messages
        messages.any? ? 'Invalid parameter: ' + messages.join(', ') : ''
      end

      # @return [Boolean] true if and only if the parameter has been set
      def present?
        !unset?
      end

      # @return [Hash] json representation of the parameter
      def as_json
        value.respond_to?(:as_json) ? value.as_json : value if present?
      end

      private

      def validate_messages
        messages = []

        validate_type(messages)

        messages << invalid_type_enum_message unless validate_value_in_enum
        messages << required_parameter_missing_message unless validate_required

        messages
      end

      def unset?
        value == UNSET
      end

      def validate_blank
        if @required
          false
        else
          unset?
        end
      end

      def validate_required
        return true unless @required
        return false if unset?

        true
      end

      def validate_value_in_enum
        return true if @permitted_values.empty?

        @permitted_values.include?(value)
      end

      def validate_type(messages)
        return true if unset? || not_required_but_nil?

        # TODO: this smells, should we have a duck type that responds
        # to .validate?
        valid = case type
                when 'string'
                  validate_string
                when 'boolean'
                  validate_boolean
                when 'number', 'integer'
                  validate_number
                when 'array'
                  validate_array
                when 'object'
                  # Objects cannot be validated
                  true
                else
                  false
                end
        messages << invalid_type_message unless valid
      end

      def invalid_type_message
        "Expected valid #{type}, but was #{value.inspect}"
      end

      def invalid_type_enum_message
        "Expected one of #{@permitted_values.inspect}, but was #{value.inspect}"
      end

      def required_parameter_missing_message
        'Missing required parameter'
      end

      def not_required_but_nil?
        !@required && value.nil?
      end

      def validate_string
        value.is_a?(String)
      end

      def validate_array_contents
        value.all? { |v| !v.respond_to?(:valid?) || v.valid? }
      end

      def validate_array
        value.is_a?(Array) && validate_array_contents
      end

      def validate_boolean
        value == !!value
      end

      def validate_number
        value.is_a?(Numeric)
      end
    end
  end
end
