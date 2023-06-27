# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::AccountsPolicy < UffizziCore::ApplicationPolicy
  def index?
    context.user.present?
  end

  def show?
    context.user_access_module.any_access_to_account?(context.user, context.account)
  end
end
