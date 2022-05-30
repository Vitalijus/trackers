require 'rake'
Rails.application.load_tasks
Rake::Task['socketing:start'].invoke
