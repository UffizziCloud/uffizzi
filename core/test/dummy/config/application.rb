# frozen_string_literal: true

require_relative 'boot'

require 'byebug'
require 'rack/cors'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'uffizzi_core'

module Dummy
  class Application < Rails::Application
    config.load_defaults(Rails::VERSION::STRING.to_f)

    config.hosts = Settings.allowed_hosts

    config.middleware.insert_before(0, Rack::Cors) do
      allow do
        origins do |source|
          uri = URI.parse(source)
          Settings.allowed_hosts.any? { |host| uri.host == host || uri.host.ends_with?(host) }
        end
        resource '*', headers: :any, methods: [:get, :post, :options, :put, :patch, :delete], credentials: true
      end
    end
  end
end
