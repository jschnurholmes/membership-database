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
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |g|
      g.template_engine :haml
    end

    # Rails 7 uses a different Active Storage configuration
    config.active_storage.variant_processor = :vips if defined?(ActiveStorage)

    # Asset pipeline configuration
    config.assets.enabled = true
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.assets.paths << Rails.root.join('app', 'assets', 'images')

    # Sender address for all outgoing mail (ActionMailer default and Devise).
    config.x.mail_from = ENV.fetch('MAIL_FROM', 'admin@cdny.org')
  end
end
