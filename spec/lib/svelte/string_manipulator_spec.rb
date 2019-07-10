# frozen_string_literal: true

require 'spec_helper'

describe Svelte::StringManipulator do
  describe '#constant_name_for' do
    it 'handles numbers at the beginning' do
      expect(described_class.constant_name_for('3d')).to eq('Threed')
    end

    it 'handles numbers not at the beginning' do
      expect(described_class.constant_name_for('v1')).to eq('V1')
    end

    it 'handles capitalization at the beginning' do
      expect(described_class.constant_name_for('test')).to eq('Test')
    end

    it 'respects existing capitalization' do
      expect(described_class.constant_name_for('AnotherTest'))
        .to eq('AnotherTest')
    end

    it 'handles hyphens' do
      expect(described_class.constant_name_for('test-with-hyphens'))
        .to eq('TestWithHyphens')
    end

    it 'handles numbers and hyphens' do
      expect(described_class.constant_name_for('letters-123-moreletters'))
        .to eq('Letters123Moreletters')
    end

    it 'handles numbers at the beginning and somewhere else' do
      expect(described_class.constant_name_for('1v2')).to eq('Onev2')
    end

    it 'handles names with spaces' do
      expect(described_class.constant_name_for('A request to initiate Something awesome'))
        .to eq('ARequestToInitiateSomethingAwesome')
    end

    it 'handles names with non alfanumeric characters' do
      expect(described_class.constant_name_for('A request. With some ? stuff'))
        .to eq('ARequestWithSomeStuff')
    end
  end

  describe '#method_name_for' do
    it 'transforms simple camel case to snake case' do
      expect(described_class.method_name_for('camelCase')).to eq('camel_case')
    end

    it 'does not alter snake case' do
      expect(described_class.method_name_for('snake_case')).to eq('snake_case')
    end

    it 'can handle acronyms at the end of a string' do
      expect(described_class.method_name_for('camelCaseMadeFromXML'))
        .to eq('camel_case_made_from_xml')
    end

    it 'can handle acronyms at the beginning of a string' do
      expect(described_class.method_name_for('XMLTransformedToCamelCase'))
        .to eq('xml_transformed_to_camel_case')
    end

    it 'can handle acronyms in the middle of a string' do
      expect(described_class.method_name_for('stringToXMLToObject'))
        .to eq('string_to_xml_to_object')
    end

    it 'can handle single capital letters in the middle of a string' do
      expect(described_class.method_name_for('handleASingleCapital'))
        .to eq('handle_a_single_capital')
    end

    it 'can handle pascal case' do
      expect(described_class.method_name_for('HandlePascalCase'))
        .to eq('handle_pascal_case')
    end

    it 'can handle numbers' do
      expect(described_class.method_name_for('thisIs3DSCode'))
        .to eq('this_is_3ds_code')
      expect(described_class.method_name_for('codeThatIs3DS'))
        .to eq('code_that_is_3ds')
      expect(described_class.method_name_for('3DSCode'))
        .to eq('three_ds_code')
    end

    it 'handles names with spaces' do
      expect(described_class.method_name_for('A request to initiate Something awesome'))
        .to eq('a_request_to_initiate_something_awesome')
    end

    it 'handles names with non alfanumeric characters' do
      expect(described_class.method_name_for('A request. With some ? stuff'))
        .to eq('a_request_with_some_stuff')
    end
  end
end
