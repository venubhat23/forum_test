# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join("node_modules/bootstrap-icons/font")
Rails.application.config.assets.paths << Rails.root.join("node_modules/bootstrap/dist/js")
Rails.application.config.assets.precompile << "bootstrap.bundle.min.js"

# Chartkick + Chart.js served locally (no external CDN) for the Analytics dashboard.
Rails.application.config.assets.paths << Gem::Specification.find_by_name("chartkick").gem_dir + "/vendor/assets/javascripts"
Rails.application.config.assets.precompile << "chartkick.js"
Rails.application.config.assets.precompile << "Chart.bundle.js"
