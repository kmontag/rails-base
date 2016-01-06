# Be sure to restart your server when you modify this file.

# Get the application name dynamically
Rails.application.config.session_store :cookie_store, key: "_#{Rails.application.class.parent.to_s.underscore}_session"
