require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StarterBaseInertia
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

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

    # Allow BigDecimal and other classes for YAML serialization (audited gem)
    # This is needed for Rails 8 / Psych 5
    config.active_record.yaml_column_permitted_classes = [
      String, Integer, NilClass, Float, Time, Date, FalseClass, Hash, Array,
      DateTime, TrueClass, BigDecimal, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone,
      ActiveSupport::HashWithIndifferentAccess, Symbol
    ]
  end
end
