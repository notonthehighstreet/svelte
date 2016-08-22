module Svelte
  module ModelFactory
    # Helper class to wrap around all method generation
    class MethodFactory
      class << self
        # Defines methods needed for Svelte to a given anonymous class.
        # @param model [Class] class methods will be appended to
        def define_methods_on(model:)
          define_initialize_on(model: model)
          define_attributes_on(model: model)
          define_required_attributes_on(model: model)
          define_json_for_model_on(model: model)
          define_nested_models_on(model: model)
          define_as_json_on(model: model)
          define_to_json_on(model: model)
          define_validate_on(model: model)
          define_valid_on(model: model)
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
              nested_class_name = StringManipulator.constant_name_for(nested_class_name)
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
  end
end
