# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Account::CredentialsPolicy < UffizziCore::ApplicationPolicy
  def create?
    context.user_access_module.admin_access_to_account?(context.user, context.account)
  end
end
