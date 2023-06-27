# frozen_string_literal: true

# @resource Project

class UffizziCore::Api::Cli::V1::AccountsController < UffizziCore::Api::Cli::V1::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_accounts

  # Get projects of current user
  #
  # @path [GET] /api/cli/v1/accounts
  #
  # @response [object<projects: Array<object<id: integer, name: string>> >] 200 OK
  # @response 401 Not authorized
  def index
    accounts = current_user.accounts.order(name: :desc)

    respond_with accounts
  end

  def show
    account = current_user.accounts.find_by!(name: params[:name])

    respond_with account
  end
end
