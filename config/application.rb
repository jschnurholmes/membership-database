require_relative "boot"

require 'csv'
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Members
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Set default serializer for serialize calls
    config.active_record.default_column_serializer = JSON

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |g|
      g.template_engine :haml
    end

    # Sender address for all outgoing mail (ActionMailer default and Devise).
    config.x.mail_from = ENV.fetch('MAIL_FROM', 'admin@cdny.org')

    # Membership dates follow the organization's calendar, whatever the server's or viewer's time zone.
    config.x.organization_time_zone = 'Eastern Time (US & Canada)'

    config.time_zone = config.x.organization_time_zone
  end
end
