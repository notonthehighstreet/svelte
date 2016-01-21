require 'svelte/model_factory/parameter'

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
        attributes = parameters['properties'].keys
        model = Class.new do
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

        define_initialize_on(model: model)
        define_attributes_on(model: model)
        define_required_attributes_on(model: model)
        define_json_for_model_on(model: model)
        define_nested_models_on(model: model)
        define_as_json_on(model: model)
        define_to_json_on(model: model)
        define_validate_on(model: model)
        define_valid_on(model: model)

        model.instance_variable_set('@json_for_model', parameters.freeze)

        models[model_name] = model
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

    def define_initialize_on(model:)
      model.send(:define_method, :initialize, lambda do
        (required_attributes - nested_models.keys).each do |required|
          public_send("#{required}=", Parameter::UNSET)
        end
        required_nested_models = nested_models.keys & required_attributes
        nested_models.each do |nested_model_name, nested_model_info|
          return unless required_nested_models.include?(nested_model_name)
          nested_class_name = public_send("#{nested_model_name}=",
                                          nested_model_info['$ref']
                                            .split('/').last)
          nested_class_name = self.class.name.gsub(/::[^:]*\z/, '::') +
                              nested_class_name
          public_send("#{nested_model_name}=",
                      Object.const_get(nested_class_name).new)
        end
      end)
    end

    def define_validate_on(model:)
      model.send(:define_method, :validate, lambda do
        invalid_params = {}
        attributes.each do |attribute|
          if public_send(attribute).respond_to?(:validate)
            result = public_send(attribute).validate
            invalid_params[attribute] = result unless result.empty?
          end
        end
        invalid_params
      end)
    end

    def define_valid_on(model:)
      model.send(:define_method, :valid?, lambda do
        validate.empty?
      end)
    end

    def define_to_json_on(model:)
      model.send(:define_method, :to_json, lambda do
        as_json.to_json
      end)
    end

    def define_attributes_on(model:)
      model.send(:define_method, :attributes, lambda do
        @attributes ||= json_for_model['properties'].keys
      end)
    end

    def define_as_json_on(model:)
      model.send(:define_method, :as_json, lambda do
        structure = {}
        attributes.each do |attribute|
          value = if public_send(attribute).respond_to?(:as_json)
                    public_send(attribute).as_json
                  else
                    public_send(attribute)
                  end

          structure[attribute] = value unless value.nil?
        end

        if structure.empty?
          nil
        else
          symbolised_structure = {}
          structure.each do |key, value|
            symbolised_structure[key.to_sym] = value
          end
          symbolised_structure
        end
      end)
    end

    def define_json_for_model_on(model:)
      model.send(:define_method, :json_for_model, lambda do
        self.class.instance_variable_get('@json_for_model')
      end)
    end

    def define_nested_models_on(model:)
      model.send(:define_method, :nested_models, lambda do
        json_for_model['properties']
          .select { |_property, sub_properties| sub_properties.key?('$ref') }
      end)
    end

    def define_required_attributes_on(model:)
      model.send(:define_method, :required_attributes, lambda do
        @required_attributes ||= json_for_model.fetch('required', [])
      end)
    end
  end
end
