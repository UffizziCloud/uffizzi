# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::AccountsPolicy < UffizziCore::ApplicationPolicy
  def index?
    context.user.present?
  end

  def show?
    context.user.present?
  end
end
