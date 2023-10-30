# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Clusters::IngressesPolicy < UffizziCore::ApplicationPolicy
  def index?
    return true if context.user_access_module.admin_access_to_project?(context.user, context.project)

    context.cluster.deployed_by_id == context.user.id
  end
end
