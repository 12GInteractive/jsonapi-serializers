require 'factory_bot'
require './lib/jsonapi-serializers'
require './spec/support/serializers'
require './spec/support/serializer_spec_helpers'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include SerializerSpecHelpers

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    # Force FactoryBot sequences to be fully reset before each test run to simplify ID testing
    # since we are not using a database or real fixtures. Inside of each test case, IDs will
    # increment per type starting at 1.
    FactoryBot.reload
    load './spec/support/factory.rb'
  end
end
