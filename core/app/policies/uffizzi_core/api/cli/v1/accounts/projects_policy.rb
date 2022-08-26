# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Accounts::ProjectsPolicy < UffizziCore::ApplicationPolicy
  def create?
    context.user_access_module.admin_or_developer_access_to_account?(context.user, context.account)
  end
end
