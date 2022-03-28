# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::SecretsPolicy < UffizziCore::ApplicationPolicy
  def index?
    context.user_access_module.any_access_to_project?(context.user, context.project)
  end

  def bulk_create?
    context.user_access_module.admin_or_developer_access_to_project?(context.user, context.project)
  end

  def destroy?
    context.user_access_module.admin_or_developer_access_to_project?(context.user, context.project)
  end
end
