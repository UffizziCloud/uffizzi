# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'], size: 2 }
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'], size: 20 }
end

if Sidekiq.server?
  Rails.application.config.after_initialize do
    Sidekiq::Cron::Job.destroy_all!
    schedule_file = 'config/schedule.yml'

    if File.exist?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
    end
  end
end

if Settings.sidekiq.login.present?
  Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
    valid_login = ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(username),
      ::Digest::SHA256.hexdigest(Settings.sidekiq.login),
    )
    valid_password = ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(password),
      ::Digest::SHA256.hexdigest(Settings.sidekiq.password),
    )
    valid_login & valid_password
  end
end
