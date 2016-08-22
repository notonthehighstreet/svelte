require 'svelte/model_factory/parameter'
require 'svelte/model_factory/method_factory'

module Svelte
  # Bridging the gap between an application and any external service that
  # publishes its API as a Swagger JSON spec.
  # @note This module is supposed to be extended not used directly
  module ModelFactory
    # Creates typed Ruby objects from JSON definitions. These definitions are
    # found in the Swagger JSON spec as a top-level key, "definitions".
    # @param json [Hash] hash of a swagger models definition
    # @return [Hash] A hash of model names to models created
    def define_models(json)
      return unless json
      models = {}
      model_definitions = json['definitions']
      model_definitions.each do |model_name, parameters|
        model = create_model(parameters: parameters)
        MethodFactory.define_methods_on(model: model)
        model.instance_variable_set('@json_for_model', parameters.freeze)

        constant_name_for_model = StringManipulator.constant_name_for(model_name)
        models[constant_name_for_model] = model
      end

      models.each do |model_name, model|
        const_set(model_name, model)
      end
    end

    # Creates typed Ruby objects from JSON String definitions. These definitions
    # are found in the Swagger JSON spec as a top-level key, "models".
    # @param string [String] string of json for a swagger models definition
    # @return [Hash] A hash of model names to models created
    def define_models_from_json_string(string)
      define_models(JSON.parse(string)) if string
    end

    # Creates typed Ruby objects from JSON File definitions. These definitions
    # are found in the Swagger JSON spec as a top-level key, "models".
    # @param file [String] path to a json file for a swagger models definition
    # @return [Hash] A hash of model names to models created
    def define_models_from_file(file)
      define_models_from_json_string(File.read(file)) if file
    end

    private

    def create_model(parameters:)
      attributes = parameters['properties'].keys
      Class.new do
        attr_reader(*attributes.map(&:to_sym))

        parameters['properties'].each do |attribute, options|
          define_method("#{attribute}=", lambda do |value|
            if public_send(attribute).nil? || !public_send(attribute).present?
              permitted_values = options.fetch('enum', [])
              required = parameters.fetch('required', []).include?(attribute)
              instance_variable_set(
                "@#{attribute}",
                Parameter.new(options['type'],
                              permitted_values: permitted_values,
                              required: required)
              )
            end

            instance_variable_get("@#{attribute}").value = value
          end)
        end
      end
    end
  end
end
