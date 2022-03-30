# frozen_string_literal: true

require_relative 'lib/uffizzi_core/version'
# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name        = 'uffizzi_core'
  spec.version     = UffizziCore::VERSION
  spec.authors     = ['Josh Thurman', 'Grayson Adkins']
  spec.email       = ['info@uffizzi.com']

  spec.summary = 'uffizzi-core'
  spec.description = 'uffizzi-core'
  spec.homepage = 'https://uffizzi.com'
  spec.license = 'Apache-2.0'
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/UffizziCloud/uffizzi_core'
  spec.metadata['changelog_uri'] = 'https://github.com/UffizziCloud/uffizzi_core/blob/master/CHANGELOG.md'

  spec.files = Dir['{app,config,db,lib,swagger}/**/*', 'LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'aasm'
  spec.add_dependency 'actionpack', '~> 6.1.0'
  spec.add_dependency 'active_model_serializers'
  spec.add_dependency 'activerecord',  '~> 6.1.0'
  spec.add_dependency 'activesupport', '~> 6.1.0'
  spec.add_dependency 'ancestry'
  spec.add_dependency 'aws-sdk-ecr', '~> 1.47'
  spec.add_dependency 'aws-sdk-eventbridge', '~> 1.30'
  spec.add_dependency 'aws-sdk-iam', '~> 1.61'
  spec.add_dependency 'dotenv'
  spec.add_dependency 'enumerize'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_curl'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'hashie'
  spec.add_dependency 'jwt'
  spec.add_dependency 'kaminari'
  spec.add_dependency 'octokit'
  spec.add_dependency 'pg', '>= 0.18', '< 2.0'
  spec.add_dependency 'pundit'
  spec.add_dependency 'rails', '~> 6.1.0'
  spec.add_dependency 'ransack'
  spec.add_dependency 'responders'
  spec.add_dependency 'rolify'
  spec.add_dependency 'rswag-api'
  spec.add_dependency 'rswag-ui'
  spec.add_dependency 'sidekiq'
  spec.add_dependency 'swagger_yard'
  spec.add_dependency 'virtus'

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bcrypt', '~> 3.1.7'
  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'config'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-hooks'
  spec.add_development_dependency 'minitest-power_assert'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-inline'
  spec.add_development_dependency 'puma'
  spec.add_development_dependency 'rack-cors'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'webmock'
end
# rubocop:enable Metrics/BlockLength
