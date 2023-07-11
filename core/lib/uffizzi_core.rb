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
require 'enumerize'
require 'jwt'
require 'kaminari'
require 'octokit'
require 'pg'
require 'pundit'
require 'ransack'
require 'responders'
require 'rolify'
require 'rswag/api'
require 'rswag/ui'
require 'sidekiq'
require 'virtus'
require 'faraday/follow_redirects'

module UffizziCore
  mattr_accessor :dependencies, default: {
    rbac: 'UffizziCore::Rbac::UserAccessService',
    deployment_memory_module: 'UffizziCore::Deployment::MemoryService',
  }
  mattr_accessor :table_names, default: {
    accounts: :uffizzi_core_accounts,
    activity_items: :uffizzi_core_activity_items,
    builds: :uffizzi_core_builds,
    clusters: :uffizzi_core_clusters,
    comments: :uffizzi_core_comments,
    compose_files: :uffizzi_core_compose_files,
    config_files: :uffizzi_core_config_files,
    container_config_files: :uffizzi_core_container_config_files,
    containers: :uffizzi_core_containers,
    coupons: :uffizzi_core_coupons,
    credentials: :uffizzi_core_credentials,
    deployments: :uffizzi_core_deployments,
    events: :uffizzi_core_events,
    invitations: :uffizzi_core_invitations,
    memberships: :uffizzi_core_memberships,
    payments: :uffizzi_core_payments,
    prices: :uffizzi_core_prices,
    products: :uffizzi_core_products,
    projects: :uffizzi_core_projects,
    ratings: :uffizzi_core_ratings,
    repos: :uffizzi_core_repos,
    roles: :uffizzi_core_roles,
    secrets: :uffizzi_core_secrets,
    templates: :uffizzi_core_templates,
    user_projects: :uffizzi_core_user_projects,
    users: :uffizzi_core_users,
    users_roles: :uffizzi_core_users_roles,
    host_volume_files: :uffizzi_core_host_volume_files,
    container_host_volume_files: :uffizzi_core_container_host_volume_files,
    deployment_events: :uffizzi_core_deployment_events,
  }
  mattr_accessor :user_creation_sources, default: [:system, :online_registration, :google, :sso]
  mattr_accessor :user_project_roles, default: [:admin, :developer, :viewer]
  mattr_accessor :account_sources, default: [:manual]
  mattr_accessor :compose_file_kinds, default: [:main, :temporary]
  mattr_accessor :event_states, default: [:waiting, :queued, :successful, :deployed, :failed, :building, :timeout, :cancelled, :deploying]
end
