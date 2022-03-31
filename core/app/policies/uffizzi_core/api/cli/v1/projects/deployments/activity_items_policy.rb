# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::ActivityItemsPolicy < UffizziCore::ApplicationPolicy
  def index?
    context.user_access_module.any_access_to_project?(context.user, context.project)
  end
end
