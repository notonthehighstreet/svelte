module Svelte
  # Svelte error class to represent networking errors
  # It can be customized by passing a specific errror message and
  # a parent exception, which will contain the http driver specific
  # error that generated it
  class HTTPError < StandardError
    attr_reader :parent

    # Creates a new HTTPError with a message and a parent error
    # @param message [String] exception message
    # @param parent the parent exception
    def initialize(message: nil, parent: nil)
      @parent = parent
      super(message || (parent && parent.message))
    end
  end
end
