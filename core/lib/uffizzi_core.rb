# frozen_string_literal: true

require 'uffizzi_core/version'
require 'uffizzi_core/engine'

require 'aasm'
require 'active_model_serializers'
require 'ancestry'
require 'aws-sdk-ecr'
require 'aws-sdk-eventbridge'
require 'aws-sdk-iam'
require 'config'
require 'hashie'
require 'faraday'
require 'google/cloud/dns'
require 'enumerize'
require 'kaminari'
require 'octokit'
require 'pg'
require 'ransack'
require 'responders'
require 'rolify'
require 'rswag/api'
require 'rswag/ui'
require 'sidekiq'
require 'virtus'

module UffizziCore
  mattr_accessor :table_names, default: {}
end
