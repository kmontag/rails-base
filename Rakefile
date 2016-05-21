begin
  require 'single_test/tasks'
rescue LoadError  
end
require 'dotenv/tasks'

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

Rake::Task[:'assets:precompile'].enhance [:'webpack:compile']
