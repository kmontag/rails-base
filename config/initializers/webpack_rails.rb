Rails.application.configure do
  config.webpack.dev_server.manifest_host = 'webpack'
  config.webpack.dev_server.manifest_port = ENV['WEBPACK_DEV_SERVER_PORT']
  config.webpack.dev_server.port = ENV['WEBPACK_DEV_SERVER_PORT']
end
