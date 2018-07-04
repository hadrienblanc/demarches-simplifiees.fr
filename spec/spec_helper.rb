# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'database_cleaner'
require 'webmock/rspec'
require 'shoulda-matchers'
require 'devise'
require 'factory_bot'

require 'selenium/webdriver'
Capybara.javascript_driver = :headless_chrome
Capybara.ignore_hidden_elements = false

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu window-size=2560,1600) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

ActiveSupport::Deprecation.silenced = true

Capybara.default_max_wait_time = 1

# Save a snapshot of the HTML page when an integration test fails
Capybara::Screenshot.autosave_on_failure = true
# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run
# Tell Capybara::Screenshot how to take screenshots when using the headless_chrome driver
Capybara::Screenshot.register_driver :headless_chrome do |driver, path|
  driver.browser.save_screenshot(path)
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }
Dir[Rails.root.join('spec', 'factories', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

VCR.configure do |c|
  c.ignore_localhost = true
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.configure_rspec_metadata!
  c.ignore_hosts 'test.host'
end

DatabaseCleaner.strategy = :transaction

TPS::Application.load_tasks

SIADETOKEN = :valid_token if !defined? SIADETOKEN
PIPEDRIVE_TOKEN = :pipedrive_test_token if !defined? PIPEDRIVE_TOKEN

include Warden::Test::Helpers

include SmartListing::Helper
include SmartListing::Helper::ControllerExtensions

module SmartListing
  module Helper
    def view_context
      'mock'
    end
  end
end

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.filter_run_excluding disable: true
  config.color = true
  config.infer_spec_type_from_file_location!
  config.tty = true

  config.include Shoulda::Matchers::ActiveRecord, type: :model
  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::Independent, type: :model

  config.use_transactional_fixtures = false

  config.infer_base_class_for_anonymous_controllers = false

  config.run_all_when_everything_filtered = true
  config.filter_run :show_in_doc => true if ENV['APIPIE_RECORD']
  config.filter_run :focus => true

  config.order = 'random'

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  config.include FactoryBot::Syntax::Methods

  config.before(:each) do
    allow_any_instance_of(PieceJustificativeUploader).to receive(:generate_secure_token).and_return("3dbb3535-5388-4a37-bc2d-778327b9f997")
    allow_any_instance_of(ProcedureLogoUploader).to receive(:generate_secure_token).and_return("3dbb3535-5388-4a37-bc2d-778327b9f998")
  end

  config.before(:all) {
    Rake.verbose false

    Warden.test_mode!

    Typhoeus::Expectation.clear

    if Flipflop.remote_storage?
      VCR.use_cassette("ovh_storage_init") do
        CarrierWave.configure do |config|
          config.fog_credentials = { provider: 'OpenStack' }
        end
      end
    end
  }

  RSpec::Matchers.define :have_same_attributes_as do |expected|
    match do |actual|
      ignored = [:id, :procedure_id, :updated_at, :created_at]
      actual.attributes.with_indifferent_access.except(*ignored) == expected.attributes.with_indifferent_access.except(*ignored)
    end
  end
end
