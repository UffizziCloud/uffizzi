# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require_relative '../test/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

require 'awesome_print'
require 'byebug'
require 'factory_bot'
require 'faker'
require 'minitest/hooks/default'
require 'minitest-power_assert'
require 'mocha/minitest'
require 'rails/test_help'
require 'sidekiq/testing'
require 'webmock/minitest'
require 'octokit'

FactoryBot.reload
WebMock.disable_net_connect!
Sidekiq::Testing.inline!

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('fixtures', __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = "#{ActiveSupport::TestCase.fixture_path}/files"
  ActiveSupport::TestCase.fixtures(:all)
end

FactoryBot.define do
  initialize_with { new(attributes) }
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include Minitest::Hooks
  include ActiveModel::Validations
  include UffizziCore::AuthManagement
  include UffizziCore::GithubStubSupport
  include UffizziCore::ControllerStubSupport
  include UffizziCore::DockerHubStubSupport
  include UffizziCore::FixtureSupport
  include UffizziCore::GoogleRegistryStubSupport
  include UffizziCore::StubSupport
  include UffizziCore::AzureRegistryStubSupport

  setup do
    @routes = UffizziCore::Engine.routes
  end
end
