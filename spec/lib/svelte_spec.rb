require 'spec_helper'

describe Svelte do
  describe '#create' do
    let(:json) { File.read('spec/fixtures/petstore.json') }
    let(:module_name) { 'PetStore' }
    let(:options) do
      {
          protocol: 'http'
      }
    end

    shared_examples 'builds all the things' do
      let(:module_constants) do
        {
          "#{module_name}::Pet" =>
            %w(addPet updatePet getPetById updatePetWithForm deletePet),
          "#{module_name}::Pet::FindByStatus" =>
            ['findPetsByStatus'],
          "#{module_name}::Pet::FindByTags" =>
            ['findPetsByTags'],
          "#{module_name}::Pet::UploadImage" =>
            ['uploadFile'],
          "#{module_name}::Store::Inventory" =>
            ['getInventory'],
          "#{module_name}::Store::Order" =>
            %w(placeOrder getOrderById deleteOrder),
          "#{module_name}::Store::Inventory" =>
            ['getInventory'],
          "#{module_name}::User::CreateWithArray" =>
            ['createUsersWithArrayInput'],
          "#{module_name}::User::CreateWithList" =>
            ['createUsersWithListInput'],
          "#{module_name}::User::Login" =>
            ['loginUser'],
          "#{module_name}::User::Logout" =>
            ['logoutUser'],
          "#{module_name}::User" =>
            %w(createUser getUserByName updateUser deleteUser)
        }
      end

      it 'creates the correct module root inside Svelte::Service namespace' do
        expect(described_class::Service.const_defined?(module_name)).to eq(true)
      end

      it 'creates the correct module hierarchy inside the root module' do
        module_constants.each_key do |module_constant|
          expect(described_class::Service.const_defined?(module_constant))
            .to(eq(true),
                "Expected #{described_class::Service}::#{module_constant} to exist, but it doesn't")
        end
      end

      it 'creates the operations for each module' do
        module_constants.each do |module_constant, operations|
          operations.each do |operation|
            method_name = Svelte::StringManipulator.method_name_for(operation)
            expect(described_class::Service.const_get(module_constant))
              .to(respond_to(method_name),
                  "Expected module to respond to :#{operation}, but it didn't")
          end
        end
      end
    end

    context 'with an inline json' do
      before do
        described_class.create(json: json, module_name: module_name, options: options)
      end

      include_examples 'builds all the things'
    end

    context 'with an online json' do
      let(:url) { 'http://www.example.com/petstore.json' }
      
      context 'with default options' do
        before do
          stub_request(:any, url)
            .to_return(body: json, status: 200)

          described_class.create(url: url, module_name: module_name)
        end

        include_examples 'builds all the things'

        it 'raises a Svelte::HTTPException on http errors' do
          stub_request(:any, url).to_timeout

          expect { described_class.create(url: url, module_name: module_name, options: options) }
            .to raise_error(Svelte::HTTPError, "Could not get API json from #{url}")
        end
      end

      context 'with a bearer token' do
        it 'sets the correct headers' do
          stub_request(:any, url)
            .to_return(body: json, status: 200)
  
          described_class.create(url: url, module_name: module_name, options: {
            auth: { token: 'Bearer 12345' }
          })
    
          assert_requested(:any, url, headers: { 'Authorization' => 'Bearer 12345' })
        end
      end

      context 'with basic authentication' do
        let(:url_with_auth) { 'http://user:pass@www.example.com/petstore.json' }
        
        it 'sets the correct headers' do
          stub_request(:any, url_with_auth)
            .to_return(body: json, status: 200)
  
          described_class.create(url: url, module_name: module_name, options: {
            auth: { basic: { username: 'user', password: 'pass' } }
          })
  
          assert_requested(:any, url_with_auth)
        end
      end

      context 'with arbitrary headers' do
        it 'sets the correct headers' do
          stub_request(:any, url)
            .to_return(body: json, status: 200)
  
          described_class.create(url: url, module_name: module_name, options: {
            headers: { test: 'value' }
          })
  
          assert_requested(:any, url, headers: { 'test' => 'value' })
        end
      end
    end

    context 'with invalid host' do
      let(:json) { File.read('spec/fixtures/petstore_with_invalid_host.json') }

      it 'raises a JSONError exception' do
        expect { described_class.create(json: json, module_name: module_name) }
          .to raise_error(Svelte::JSONError,
                          '`host` field in JSON is invalid')
      end
    end

    context 'with invalid basePath' do
      let(:json) { File.read('spec/fixtures/petstore_with_invalid_base_path.json') }

      it 'raises a JSONError exception' do
        expect { described_class.create(json: json, module_name: module_name) }
          .to raise_error(Svelte::JSONError,
                          '`basePath` field in JSON is invalid')
      end
    end

    context 'with invalid paths' do
      let(:json) { File.read('spec/fixtures/petstore_with_invalid_paths.json') }

      it 'raises a JSONError exception' do
        expect { described_class.create(json: json, module_name: module_name) }
          .to raise_error(Svelte::JSONError,
                          'Expected JSON to contain an object of valid paths')
      end
    end

    context 'with invalid operations' do
      let(:json) { File.read('spec/fixtures/petstore_with_invalid_operations.json') }

      it 'raises a JSONError exception' do
        expect { described_class.create(json: json, module_name: module_name) }
          .to raise_error(Svelte::JSONError,
                          'Expected the path to contain a list of operations')
      end
    end

    context 'with operations missing mandatory values' do
      let(:json) { File.read('spec/fixtures/petstore_without_mandatory_operation_fields.json') }

      it 'raises a JSONError exception' do
        expect { described_class.create(json: json, module_name: module_name) }
          .to raise_error(Svelte::JSONError,
                          'Operation is missing mandatory `operationId` field')
      end
    end

    context 'with a version 1.2 JSON spec' do
      let(:json) { File.read('spec/fixtures/petstore_1.2.json') }

      it 'raises a VersionError exception' do
        expect { described_class.create(json: json, module_name: module_name) }
          .to raise_error(Svelte::VersionError,
                          'Invalid Swagger version spec supplied. Svelte supports Swagger v2 only')
      end
    end
  end
end
