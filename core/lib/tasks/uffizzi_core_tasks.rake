# frozen_string_literal: true

namespace :uffizzi_core do
  Rake::Task['install:migrations'].clear_comments

  desc 'Copy over the migration needed to the application'
  task install: :environment do
    if Rake::Task.task_defined?('uffizzi_core:install:migrations')
      Rake::Task['uffizzi_core:install:migrations'].invoke
    else
      Rake::Task['app:uffizzi_core:install:migrations'].invoke
    end
  end
end
