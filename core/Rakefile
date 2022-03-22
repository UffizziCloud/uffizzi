# frozen_string_literal: true

require 'bundler/setup'

APP_RAKEFILE = File.expand_path('test/dummy/Rakefile', __dir__)
load 'rails/tasks/engine.rake'

load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task default: :test

namespace :core do
  desc 'Generate api docs'
  task generate_docs: :environment do
    SwaggerYard.register_custom_yard_tags!

    spec = SwaggerYard::Swagger.new

    File.open('swagger/v1/swagger.json', 'w') { |f| f << JSON.pretty_generate(spec.to_h) }
  end
end
