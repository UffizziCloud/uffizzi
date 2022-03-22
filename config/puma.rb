# frozen_string_literal: true

threads_count = ENV.fetch('RAILS_THREADS_COUNT', 5)
threads threads_count, threads_count

port ENV.fetch('RAILS_PORT', 7000)
environment ENV.fetch('RAILS_ENV', 'development')

workers ENV.fetch('RAILS_WORKERS_COUNT', 18)

preload_app! if ENV.fetch('RAILS_WORKERS_COUNT').to_i.positive?

before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
