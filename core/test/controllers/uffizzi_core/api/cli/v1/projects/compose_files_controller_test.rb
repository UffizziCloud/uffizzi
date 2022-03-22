# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::ComposeFilesControllerTest < ActionController::TestCase
  setup do
    @admin = create(:user, :with_organizational_account)
    @account = @admin.organizational_account
    @developer = create(:user, :developer_in_organization, organization: @account)
    @viewer = create(:user, :viewer_in_organization, organization: @account)
    @project = create(:project, :with_members, account: @account, members: [@admin, @developer, @viewer])
    @compose_file = create(:compose_file, project: @project, added_by: @admin)
    image = generate(:image)
    image_namespace, image_name = image.split('/')
    target_branch = generate(:branch)
    repo_attributes = attributes_for(
      :repo,
      :github,
      namespace: image_namespace,
      name: image_name,
      branch: target_branch,
    )
    container_attributes = attributes_for(
      :container,
      :with_public_port,
      image: image,
      tag: target_branch,
      receive_incoming_requests: true,
      repo_attributes: repo_attributes,
    )
    template_payload = {
      containers_attributes: [container_attributes],
    }
    @credential = create(:credential, :github, :active, account: @account, provider_ref: generate(:number))
    @template = create(:template, :compose_file_source, compose_file: @compose_file, project: @project, added_by: @admin,
                                                        payload: template_payload)
  end

  test '#show - admin gets compose file' do
    sign_in @admin

    params = { project_slug: @project.slug }

    get :show, params: params, format: :json

    assert_response :success
  end

  test '#show - developer gets compose file' do
    sign_in @developer

    params = { project_slug: @project.slug }

    get :show, params: params, format: :json

    assert_response :success
  end

  test '#show - viewer gets compose file' do
    sign_in @viewer

    params = { project_slug: @project.slug }

    get :show, params: params, format: :json

    assert_response :success
  end

  test '#show - returns 404 if compose file does not exist' do
    sign_in @viewer
    @compose_file.destroy!

    params = { project_slug: @project.slug }

    get :show, params: params, format: :json

    assert_response :not_found
  end

  test '#create - updates the existing compose file for the project' do
    sign_in @admin

    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    content = json_fixture('files/github/compose_files/hello_world_compose.json')[:content]
    compose_file_attributes = base_attributes.merge(content: content, repository_id: nil)
    params = {
      project_slug: @project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
    }

    repositories_data = json_fixture('files/github/search_repositories.json')
    stub_github_repositories = stub_github_search_repositories_request(repositories_data)
    compose_container_branch = 'main'
    compose_container_repository_id = 358_291_405
    github_branch_data = json_fixture('files/github/branches/master.json')
    stubbed_github_branch_request = stub_github_branch_request(compose_container_repository_id, compose_container_branch,
                                                               github_branch_data)

    differences = {
      -> { UffizziCore::ComposeFile.count } => 0,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :created
    @compose_file.reload
    assert_equal @compose_file.content, content
    assert_equal @compose_file.path, base_attributes[:path]
    assert_equal @compose_file.source, base_attributes[:source]
    assert_requested(stub_github_repositories)
    assert_requested(stubbed_github_branch_request)
  end

  test '#create - admin creates compose file' do
    sign_in @admin

    @compose_file.destroy!
    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    content = json_fixture('files/github/compose_files/hello_world_compose.json')[:content]
    compose_file_attributes = base_attributes.merge(content: content, repository_id: nil)
    params = {
      project_slug: @project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
    }

    repositories_data = json_fixture('files/github/search_repositories.json')
    stub_github_repositories = stub_github_search_repositories_request(repositories_data)
    compose_container_branch = 'main'
    compose_container_repository_id = 358_291_405
    github_branch_data = json_fixture('files/github/branches/master.json')
    stubbed_github_branch_request = stub_github_branch_request(compose_container_repository_id, compose_container_branch,
                                                               github_branch_data)

    differences = {
      -> { UffizziCore::ComposeFile.main.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    assert_requested(stub_github_repositories)
    assert_requested(stubbed_github_branch_request)
  end

  test '#create - docker compose file' do
    sign_in @admin

    @compose_file.destroy!
    create(:credential, :docker_hub, :active, account: @account)
    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    file_content = File.read('test/fixtures/files/uffizzi-compose-vote-app-docker.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = base_attributes.merge(content: encoded_content, repository_id: nil)
    dependency = {
      path: 'configs/vote.conf',
      source: 'vote.conf',
      content: json_fixture('files/github/files/configs/vote_conf.json')[:content],
    }

    params = {
      project_slug: @project.slug,
      compose_file: compose_file_attributes,
      dependencies: [dependency],
    }

    repositories_data = json_fixture('files/github/search_repositories.json')
    stub_github_repositories = stub_github_search_repositories_request(repositories_data)
    compose_container_branch = 'main'
    compose_container_repository_id = 358_291_405
    github_branch_data = json_fixture('files/github/branches/master.json')
    stubbed_github_branch_request = stub_github_branch_request(compose_container_repository_id, compose_container_branch,
                                                               github_branch_data)

    differences = {
      -> { UffizziCore::ComposeFile.main.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    assert_not_requested(stub_github_repositories)
    assert_not_requested(stubbed_github_branch_request)
  end

  test '#create if a compose file is invalid' do
    sign_in @admin

    @compose_file.destroy!
    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    content = json_fixture('files/github/compose_files/hello_world_invalid_services.json')[:content]
    compose_file_attributes = base_attributes.merge(content: content, repository_id: nil)
    params = {
      project_slug: @project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
    }

    differences = {
      -> { UffizziCore::ComposeFile.count } => 0,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :unprocessable_entity

    response_body = JSON.parse(response.body)
    refute_empty(response_body['errors']['content'])
  end

  test '#create if a repository not found' do
    sign_in @admin

    @compose_file.destroy!
    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    content = json_fixture('files/github/compose_files/unknown_repository_compose.json')[:content]

    repositories_data = json_fixture('files/github/search_repositories.json')
    stub_github_repositories = stub_github_search_repositories_request(repositories_data)

    params = {
      project_slug: @project.slug,
      compose_file: base_attributes.merge(content: content),
      dependencies: [],
    }

    post :create, params: params, format: :json

    assert_response :unprocessable_entity
    assert_requested(stub_github_repositories)
  end

  test '#create - check vote-app-github creation' do
    sign_in @admin

    create(:credential, :github, account: @account, provider_ref: generate(:number))
    create(:credential, :docker_hub, account: @account)

    @compose_file.destroy!
    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    content = json_fixture('files/github/compose_files/vote_app_github.json')[:content]
    compose_file_attributes = base_attributes.merge(content: content)

    postgres_env_data = json_fixture('files/github/files/env_files/postgres_env.json')
    stub_github_content_request(compose_file_attributes[:repository_id], compose_file_attributes[:branch], '.env', postgres_env_data)

    repositories_data = json_fixture('files/github/search_repositories.json')
    stub_github_repositories = stub_github_search_repositories_request(repositories_data)

    differences = {
      -> { UffizziCore::Template.count } => 1,
      -> { UffizziCore::ConfigFile.count } => 1,
      -> { UffizziCore::ComposeFile.count } => 1,
    }

    dependency1 = {
      path: 'configs/vote.conf',
      source: 'vote.conf',
      content: json_fixture('files/github/files/configs/vote_conf.json')[:content],
    }

    dependency2 = {
      path: '.env',
      source: '.env',
      content: json_fixture('files/github/files/env_files/postgres_env.json')[:content],
    }

    params = {
      project_slug: @project.slug,
      compose_file: base_attributes.merge(content: content),
      dependencies: [dependency1, dependency2],
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    assert_requested(stub_github_repositories)
  end

  test '#destroy - deletes compose file' do
    sign_in @admin

    params = { project_slug: @project.slug }

    differences = {
      -> { UffizziCore::ComposeFile.count } => -1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => -1,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_response :no_content
  end

  test '#destroy - when compose_file not found' do
    sign_in @developer

    @compose_file.destroy!
    params = { project_slug: @project.slug }

    delete :destroy, params: params, format: :json

    assert_response :not_found
  end
end
