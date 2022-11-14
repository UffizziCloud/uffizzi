# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::DeploymentsPolicy < UffizziCore::ApplicationPolicy
  def index?
    context.user_access_module.any_access_to_project?(context.user, context.project)
  end

  def show?
    context.user_access_module.any_access_to_project?(context.user, context.project)
  end

  def create?
    if context.params["metadata"]["labels"]["github"].present?
      context.user_access_module.any_access_to_project?(context.user, context.project)
    else
      context.user_access_module.admin_or_developer_access_to_project?(context.user, context.project)
    end
  end

  def update?
    context.user_access_module.admin_or_developer_access_to_project?(context.user, context.project)
  end

  def destroy?
    context.user_access_module.admin_or_developer_access_to_project?(context.user, context.project)
  end

  def deploy_containers?
    context.user_access_module.admin_or_developer_access_to_project?(context.user, context.project)
  end
end
