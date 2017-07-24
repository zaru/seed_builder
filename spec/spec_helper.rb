require "bundler/setup"
require "seed_builder"
require "pry"

require "carrierwave"
require "paperclip"
require "carrierwave/orm/activerecord"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
