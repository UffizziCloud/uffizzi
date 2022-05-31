# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ProjectsPolicy < UffizziCore::ApplicationPolicy
  def index?
    context.user_access_module.any_access_to_account?(context.user, context.account)
  end

  def show?
    context.user_access_module.any_access_to_account?(context.user, context.account)
  end

  def create?
    context.user_access_module.admin_or_developer_access_to_account?(context.user, context.account)
  end

  def destroy?
    context.user_access_module.admin_or_developer_access_to_account?(context.user, context.account)
  end
end
