# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Account::CredentialsControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_organizational_account)
    @account = @user.organizational_account
    @project = create(:project, :with_members, account: @account, members: [@user])

    sign_in @user

    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
  end

  teardown do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#index returns a list of credetials' do
    create(:credential, :docker_hub, account: @account)
    create(:credential, :amazon, account: @account)

    params = { account_id: @account.id }

    get :index, params: params, format: :json

    assert_response :success

    data = JSON.parse(response.body)
    assert_equal(['UffizziCore::Credential::DockerHub', 'UffizziCore::Credential::Amazon'], data['credentials'])
  end

  test '#create docker hub credential' do
    stubbed_dockerhub_login = stub_dockerhub_login

    attributes = attributes_for(:credential, :docker_hub)
    params = { account_id: @account.id, credential: attributes }

    differences = {
      -> { UffizziCore::Credential.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    assert_requested(stubbed_dockerhub_login)
  end

  test '#create if docker hub auth is failed' do
    data = json_fixture('files/dockerhub/login_fail.json')
    stubbed_dockerhub_login = stub_dockerhub_login_fail(data)

    attributes = attributes_for(:credential, :docker_hub)
    params = { account_id: @account.id, credential: attributes }

    differences = {
      -> { UffizziCore::Credential.count } => 0,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :unprocessable_entity
    assert_requested(stubbed_dockerhub_login)
  end

  test '#create azure credential' do
    registry_url = generate(:url)
    oauth2_token_response = { access_token: generate(:string) }

    stubbed_azure_registry_oauth2_token = stub_azure_registry_oauth2_token(registry_url, oauth2_token_response)

    attributes = attributes_for(:credential, :azure, registry_url: registry_url)
    params = { account_id: @account.id, credential: attributes }

    differences = {
      -> { UffizziCore::Credential.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end
    assert_requested stubbed_azure_registry_oauth2_token
    assert_response :success
  end

  test '#create google credential' do
    attributes = attributes_for(:credential, :google)
    params = { account_id: @account.id, credential: attributes }
    token_response = { token: generate(:string) }

    stubbed_google_registry_token = stub_google_registry_token(token_response)

    differences = {
      -> { UffizziCore::Credential.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end
    assert_requested stubbed_google_registry_token
    assert_response :success
  end

  test '#create amazon credential' do
    attributes = attributes_for(:credential, :amazon)
    params = { account_id: @account.id, credential: attributes }

    UffizziCore::Amazon::CredentialService.expects(:credential_correct?).at_least(1).returns(true)

    differences = {
      -> { UffizziCore::Credential.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
  end

  test '#create github_container_registry credential' do
    attributes = attributes_for(:credential, :github_container_registry)
    params = { account_id: @account.id, credential: attributes }
    registry_url = attributes[:registry_url]
    token_response = { token: generate(:string) }
    stub_github_container_registry_access_token(registry_url, token_response)

    differences = {
      -> { UffizziCore::Credential.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
  end

  test '#update' do
    stub_dockerhub_login

    credentials = create(:credential, :docker_hub, account: @account)
    credentials_attributes = attributes_for(:credential, :docker_hub, account: @account)

    params = { credential: credentials_attributes, type: credentials_attributes[:type] }

    put :update, params: params, format: :json
    assert_response :success
    assert { UffizziCore::Credential.one? }
    assert { UffizziCore::Credential.first.username == credentials_attributes[:username] }
  end

  test '#create duplicate credential' do
    stub_dockerhub_login
    stub_controller

    credential = create(:credential, :docker_hub, account: @account)

    differences = { -> { UffizziCore::Credential.count } => 0 }
    attributes = attributes_for(:credential, :docker_hub, account: @account)
    params = { account_id: @account.id, credential: attributes }

    assert_difference differences do
      post :create, params: params, format: :json
    end
    assert_response :unprocessable_entity
    assert_equal UffizziCore::Credential.last.id, credential.id
  end

  test '#check_credential valid credential' do
    stub_dockerhub_login
    stub_controller

    attributes = attributes_for(:credential, :docker_hub, account: @account)
    params = { type: attributes[:type] }

    post :check_credential, params: params, format: :json

    assert_response :success
  end

  test '#check_credential duplicate credential' do
    stub_dockerhub_login
    stub_controller

    credential = create(:credential, :docker_hub, account: @account)

    params = { type: credential.type }

    post :check_credential, params: params, format: :json

    assert_response :unprocessable_entity
  end

  test '#destroy docker hub credential' do
    credential = create(:credential, :docker_hub, account: @account)

    params = { type: credential.type }

    differences = {
      -> { UffizziCore::Credential.count } => -1,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :success
  end

  test '#destroy azure credential' do
    credential = create(:credential, :azure, account: @account)

    params = { type: credential.type }

    differences = {
      -> { UffizziCore::Credential.count } => -1,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :success
  end

  test '#destroy google credential' do
    credential = create(:credential, :google, account: @account)

    params = { type: credential.type }

    differences = {
      -> { UffizziCore::Credential.count } => -1,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :success
  end

  test '#destroy amazon credential' do
    credential = create(:credential, :amazon, account: @account)

    params = { type: credential.type }

    differences = {
      -> { UffizziCore::Credential.count } => -1,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :success
  end

  test '#destroy github_container_registry credential' do
    credential = create(:credential, :github_container_registry, account: @account)

    params = { type: credential.type }

    differences = {
      -> { UffizziCore::Credential.count } => -1,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :success
  end

  test '#destroy unexisted credential' do
    params = { type: UffizziCore::Credential::DockerHub.name }

    differences = {
      -> { UffizziCore::Credential.count } => 0,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :not_found
  end
end
