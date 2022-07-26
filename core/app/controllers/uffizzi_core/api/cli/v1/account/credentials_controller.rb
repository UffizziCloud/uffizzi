# frozen_string_literal: true

# @resource Account/Credential
class UffizziCore::Api::Cli::V1::Account::CredentialsController < UffizziCore::Api::Cli::V1::Account::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_account_credentials

  # Get a list of accounts credential
  #
  # @path [GET] /api/cli/v1/account/credentials
  #
  # @parameter credential(required,body) [object<username:string, password: string, type:string>]
  def index
    credentials = resource_account.credentials.pluck(:type)

    render json: { credentials: credentials }, status: :ok
  end

  # rubocop:disable Layout/LineLength
  # Create account credential
  #
  # @path [POST] /api/cli/v1/account/credentials
  #
  # @parameter credential(required,body) [object<username:string, password: string, type:string>]
  # @response [object<id:integer, username:string, password:string, type:string, state:string>] 201 Created successfully
  # @response [object<errors>] 422 Unprocessable entity
  #
  # @example
  #    type can be one of UffizziCore::Credential::Amazon, UffizziCore::Credential::Azure, UffizziCore::Credential::DockerHub, UffizziCore::Credential::Google, UffizziCore::Credential::GithubContainerRegistry
  # rubocop:enable Layout/LineLength
  def create
    credential_form = UffizziCore::Api::Cli::V1::Account::Credential::CreateForm.new
    credential_form.assign_attributes(credential_params)
    credential_form.account = resource_account
    credential_form.registry_url = registry_url(credential_form)
    credential_form.username = '_json_key' if credential_form.google?
    credential_form.activate

    UffizziCore::Account::CreateCredentialJob.perform_async(credential_form.id) if credential_form.save

    respond_with credential_form
  end

  # Update existing credentials of the given type
  #
  # @path [PUT] /api/cli/v1/account/credentials/{type}
  #
  # @parameter type(required,path) [string] Credentials type
  # @parameter credential(required,body) [object<type:string>]
  # @response 422 Unprocessable entity
  # @response 200 OK
  def update
    credentials = resource_account.credentials.find_by!(type: params[:type])
    credentials_form = credentials.becomes(UffizziCore::Api::Cli::V1::Account::Credential::UpdateForm)
    credentials_form.assign_attributes(credential_params)

    if credentials_form.save
      respond_with credentials_form
    else
      respond_with credentials_form, status: :unprocessable_entity
    end
  end

  # Check if credential of the type already exists in the account
  #
  # @path [GET] /api/cli/v1/account/credentials/{type}/check_credential
  #
  # @parameter credential(required,body) [object<type:string>]
  # @response 422 Unprocessable entity
  # @response 200 OK
  def check_credential
    credential_form = UffizziCore::Api::Cli::V1::Account::Credential::CheckCredentialForm.new
    credential_form.type = params[:type]
    credential_form.account = resource_account
    if credential_form.valid?
      respond_with credential_form
    else
      respond_with credential_form.errors, status: :unprocessable_entity
    end
  end

  # Delete account credential
  #
  # @path [DELETE] /api/cli/v1/account/credentials/{type}
  #
  # @parameter type(required,path) [string] Type of the credential
  # @response 204 No Content
  # @response 401 Not authorized
  # @response [object<errors: object<title: string>>] 404 Not found
  def destroy
    credential = resource_account.credentials.find_by!(type: params[:type])
    credential.destroy
  end

  private

  def credential_params
    params.require(:credential)
  end

  def registry_url(credential_form)
    if credential_form.docker_hub?
      Settings.docker_hub.registry_url
    elsif credential_form.google?
      Settings.google.registry_url
    elsif credential_form.github_container_registry?
      Settings.github_container_registry.registry_url
    else
      credential_form.registry_url
    end
  end
end
