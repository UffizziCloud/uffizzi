# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Accounts::User::Projects::ClustersPolicy < UffizziCore::ApplicationPolicy
  def index?
    context.user_access_module.admin_or_developer_access_to_project?(context.user, context.account)
  end
end
