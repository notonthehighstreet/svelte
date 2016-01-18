module Svelte
  # Provides helper methods to manipulate strings in order to generate
  # valid constant and method names from them
  module StringManipulator
    class << self
      # Generates a valid Ruby constant name as similar as possible to `string`
      # @param string [String] input string
      # @return [String] a valid Ruby constant name based on `string`
      def constant_name_for(string)
        s = fixify(string)
        pascalize(s)
      end

      # Generates a valid Ruby method name as similar as possible to `string`
      # @param string [String] input string
      # @return [String] a valid Ruby method name based on `string`
      def method_name_for(string)
        s = fixify(string)
        snakify(s)
      end

      private

      # Converts a single digit to a number.
      def fixify(string)
        dictionary = {
          '1' => 'One',
          '2' => 'Two',
          '3' => 'Three',
          '4' => 'Four',
          '5' => 'Five',
          '6' => 'Six',
          '7' => 'Seven',
          '8' => 'Eight',
          '9' => 'Nine',
          '0' => 'Zero'
        }

        string.sub(/^(\d+)/) { dictionary[Regexp.last_match[1]] }
      end

      def pascalize(string)
        string.split('-').map(&method(:capitalize_first_char)).join
      end

      def capitalize_first_char(string)
        string.sub(/^(.)/) { Regexp.last_match[1].capitalize }
      end

      def snakify(string)
        string.gsub('-', '_').
          # This first regex handles the case of a string ending in an acroynm
          gsub(/([a-z])([A-Z]+)\z/, '\1_\2').
          # This regex then handles acronyms in other places, including at
          # the start of the string
          # This is aided by the fact that a acronym cannot be preceded by
          # an unrelated capital in camel case.
          gsub(/([A-Z]+)([A-Z])([^A-Z_])/, '\1_\2\3').
          # This then ensures all lower case letters that
          # are not yet followed by an underscore
          # or another lower case letter get an underscored appended.
          gsub(/([a-z])([^a-z_])/, '\1_\2').downcase
      end
    end
  end
end
