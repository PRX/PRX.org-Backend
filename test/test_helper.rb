ENV["RAILS_ENV"] = "test"

if ENV['TRAVIS']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
require File.expand_path("../../config/environment", __FILE__)

require "rails/test_help"

require 'factory_girl'

require "minitest/rails"
require "minitest/hell" # This makes things slower but enforces threadsafety
require "minitest/reporters"
require 'minitest/autorun'
require 'minitest/spec'

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
