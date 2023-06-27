# frozen_string_literal: true

# @resource Project

class UffizziCore::Api::Cli::V1::AccountsController < UffizziCore::Api::Cli::V1::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_accounts

  # Get accounts of current user
  #
  # @path [GET] /api/cli/v1/accounts
  #
  # @response [object<accounts: Array<object<id: integer, name: string>> >] 200 OK
  # @response 401 Not authorized
  def index
    accounts = current_user.accounts.order(name: :desc)

    respond_with accounts
  end

  # Get account by name
  #
  # @path [GET] /api/cli/v1/accounts/{name}
  #
  # @response [object<account: <object<id: integer, name: string, projects: Array<object<id: integer, slug: string>>>> >] 200 OK
  # @response 401 Not authorized
  def show
    raise ActiveRecord::NotFound if resource_account.blank?

    respond_with resource_account
  end

  private

  def policy_context
    account = resource_account || current_user.default_account

    UffizziCore::AccountContext.new(current_user, user_access_module, account, params)
  end

  def resource_account
    @resource_account ||= current_user.accounts.find_by(name: params[:name])
  end
end
