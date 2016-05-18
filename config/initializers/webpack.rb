# Monkey-patch a fix for https://github.com/mipearson/webpack-rails/issues/15
require 'webpack/rails/manifest'
module Webpack
  module Rails
    class Manifest
      class << self
        private
        def load_dev_server_manifest
          http = Net::HTTP.new(
            ::Rails.configuration.webpack.dev_server.host,
            ::Rails.configuration.webpack.dev_server.port)
          http.use_ssl = ::Rails.configuration.webpack.dev_server.https
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.get(dev_server_path).body
        rescue => e
          raise ManifestLoadError.new("Could not load manifest from webpack-dev-server at #{dev_server_url} - is it running, and is stats-webpack-plugin loaded?", e)
        end

        def dev_server_url
          "http://#{::Rails.configuration.webpack.dev_server.host}:#{::Rails.configuration.webpack.dev_server.port}#{dev_server_path}"
        end
      end
    end
  end
end
