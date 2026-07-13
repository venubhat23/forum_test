require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BusinessNetworkForum
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

    # Forum logos are uploaded only by super admins (a small, trusted group),
    # so allow SVG to render inline instead of Rails' default of forcing it
    # to download (a hardening against XSS via untrusted SVG uploads).
    config.active_storage.content_types_to_serve_as_binary -= [ "image/svg+xml" ]
    config.active_storage.content_types_allowed_inline += [ "image/svg+xml" ]

    # R2's S3-compatible endpoint always requires a signed request, even for
    # reads, unless a bucket has a separate public r2.dev/custom domain
    # configured (it doesn't here). Proxying makes image_tag/rails_blob_path
    # stream the file through the app using our R2 credentials, so uploads
    # display correctly without needing that extra Cloudflare setup.
    config.active_storage.resolve_model_to_route = :rails_storage_proxy
  end
end
