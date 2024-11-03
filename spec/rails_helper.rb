# spec/rails_helper.rb

# Require the necessary testing and configuration files
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'factory_bot_rails'  # Add this line to require FactoryBot

# Configure RSpec
RSpec.configure do |config|
  # Include FactoryBot syntax to simplify calls to factories
  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

# Configure Shoulda Matchers to use RSpec as the test framework and full Rails library
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
