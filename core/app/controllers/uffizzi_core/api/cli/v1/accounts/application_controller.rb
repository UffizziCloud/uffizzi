# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Accounts::ApplicationController < UffizziCore::Api::Cli::V1::ApplicationController
  def resource_account
    @resource_account ||= current_user.accounts.find(params[:account_id])
  end

  def policy_context
    UffizziCore::AccountContext.new(current_user, user_access_module, resource_account, params)
  end
end
