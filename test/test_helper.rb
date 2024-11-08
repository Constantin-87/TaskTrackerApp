# Start SimpleCov for code coverage
require "simplecov"
SimpleCov.start do
  # Optional: Filter out files you don't want to track
  add_filter "/config/"
  add_filter "/test/" # Exclude tests themselves from coverage

  # Optional: Group files by type
  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Helpers", "app/helpers"
  add_group "Services", "app/services"
end

puts "SimpleCov started, generating test coverage report..."

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Disable parallel tests
    self.use_transactional_tests = true
    parallelize(workers: 1)
  end
end
