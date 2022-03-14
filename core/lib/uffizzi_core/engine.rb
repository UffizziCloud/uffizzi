# frozen_string_literal: true

require 'active_model_serializers'

module UffizziCore
  class Engine < ::Rails::Engine
    isolate_namespace UffizziCore

    config.uffizzi_core = ActiveSupport::OrderedOptions.new

    config.uffizzi_core.table_names = {
      accounts: :uffizzi_core_accounts,
      activity_items: :uffizzi_core_activity_items,
      builds: :uffizzi_core_builds,
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
      templates: :uffizzi_core_templates,
      user_projects: :uffizzi_core_user_projects,
      users: :uffizzi_core_users,
      users_roles: :uffizzi_core_users_roles,
    }

    ActiveModelSerializers.config.adapter = :json
  end
end
