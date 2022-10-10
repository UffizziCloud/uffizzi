# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::DeploymentsControllerTest < ActionController::TestCase
  setup do
    @admin = create(:user, :with_personal_account)
    @account = @admin.personal_account
    @project = create(:project, :with_members, account: @admin.personal_account, members: [@admin])
    @deployment = create(:deployment, project: @project, state: UffizziCore::Deployment::STATE_ACTIVE)
    @metadata = {
      'labels' => {
        'github' => {
          'repository' => 'feature/#24_My_awesome_feature',
          'pull_request' => {
            'number' => '24',
          },
        },
      },
    }

    @deployment.update!(subdomain: UffizziCore::DeploymentService.build_subdomain(@deployment))
    @credential = create(:credential, :github_container_registry, account: @account)

    image = generate(:image)
    image_namespace, image_name = image.split('/')
    target_branch = generate(:branch)
    repo_attributes = attributes_for(
      :repo,
      :docker_hub,
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
    @template = create(:template, :compose_file_source, compose_file: @compose_file, project: @project, added_by: @admin,
                                                        payload: template_payload)

    sign_in @admin
  end

  test '#create - from the existing compose file' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!

    file_content = File.read('test/fixtures/files/test-compose-success.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file = create(:compose_file, project: @project, added_by: @admin, content: encoded_content)
    image = generate(:image)
    image_namespace, image_name = image.split('/')
    target_branch = generate(:branch)
    repo_attributes = attributes_for(
      :repo,
      :docker_hub,
      namespace: image_namespace,
      name: image_name,
      branch: target_branch,
    )
    container_attributes = attributes_for(
      :container,
      :with_public_port,
      :with_named_volume,
      image: image,
      tag: target_branch,
      healthcheck: { test: ['CMD', 'curl', '-f', 'https://localhost'] },
      receive_incoming_requests: true,
      repo_attributes: repo_attributes,
    )
    template_payload = {
      containers_attributes: [container_attributes],
    }
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)
    stub_dockerhub_repository('library', 'redis')

    params = { project_slug: @project.slug, compose_file: {}, dependencies: [], metadata: {} }

    differences = {
      -> { UffizziCore::Deployment.active.count } => 1,
      -> { UffizziCore::Repo::DockerHub.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success

    subdomains = UffizziCore::Deployment.active.map(&:subdomain)
    assert_nil(subdomains.detect { |s| s.include?('_') })

    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - from the existing compose file with metadata' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!

    file_content = File.read('test/fixtures/files/test-compose-success.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file = create(:compose_file, project: @project, added_by: @admin, content: encoded_content)
    image = generate(:image)
    image_namespace, image_name = image.split('/')
    target_branch = generate(:branch)
    repo_attributes = attributes_for(
      :repo,
      :docker_hub,
      namespace: image_namespace,
      name: image_name,
      branch: target_branch,
    )
    container_attributes = attributes_for(
      :container,
      :with_public_port,
      :with_named_volume,
      image: image,
      tag: target_branch,
      healthcheck: { test: ['CMD', 'curl', '-f', 'https://localhost'] },
      receive_incoming_requests: true,
      repo_attributes: repo_attributes,
    )
    template_payload = {
      containers_attributes: [container_attributes],
    }
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)
    stub_dockerhub_repository('library', 'redis')
    params = { project_slug: @project.slug, compose_file: {}, dependencies: [], metadata: @metadata }

    post :create, params: params, format: :json

    assert_response :success
    deployment = compose_file.deployments.first
    assert_equal(@metadata, deployment.metadata)
    assert_equal(deployment.subdomain.downcase, deployment.subdomain)

    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - from the existing compose file when credentials are removed' do
    create_deployment_request = stub_controller_create_deployment_request
    file_content = File.read('test/fixtures/files/uffizzi-compose-vote-app-docker.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file = create(:compose_file, project: @project, added_by: @admin, content: encoded_content)
    image = generate(:image)
    image_namespace, image_name = image.split('/')
    target_branch = generate(:branch)
    repo_attributes = attributes_for(
      :repo,
      :docker_hub,
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
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)
    stub_dockerhub_private_repository('library', 'redis')

    params = { project_slug: @project.slug, compose_file: {}, dependencies: [], metadata: {} }

    differences = {
      -> { UffizziCore::Deployment.active.count } => 0,
      -> { UffizziCore::Repo::DockerHub.count } => 0,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :unprocessable_entity
    assert_not_requested(create_deployment_request)
  end

  test '#create - from the existing compose file - when the file is invalid' do
    create(:credential, :github_container_registry, account: @admin.personal_account)
    compose_file = create(:compose_file, :invalid_file, project: @project, added_by: @admin)
    image = generate(:image)
    image_namespace, image_name = image.split('/')
    target_branch = generate(:branch)
    repo_attributes = attributes_for(
      :repo,
      :docker_hub,
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
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)

    params = { project_slug: @project.slug, compose_file: {}, dependencies: [], metadata: {} }

    differences = {
      -> { UffizziCore::Deployment.active.count } => 0,
      -> { UffizziCore::Repo::DockerHub.count } => 0,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :unprocessable_entity
  end

  test '#create - when compose file does not exist and no params given' do
    params = {
      project_slug: @project.slug,
      compose_file: {},
      dependencies: [],
      metadata: {},
    }

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 0,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 0,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :not_found
  end
  test '#create - when compose file does not exist and use docker registry without auth' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
    stub_docker_registry_manifests('https://ttl.sh', 'abc', '1h')

    compose_file_content = File.read('test/fixtures/files/uffizzi-compose-docker-registry-anonymous.yml')
    encoded_compose_file_content = Base64.encode64(compose_file_content)

    compose_file = {
      source: '/gem/tmp/docker-compose.uffizzi.yaml',
      path: '/gem/tmp/docker-compose.uffizzi.yaml',
      content: encoded_compose_file_content,
    }

    params = {
      project_slug: @project.slug,
      compose_file: compose_file,
      dependencies: [],
      metadata: {},
    }

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { UffizziCore::Container.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - with content when compose file does not exist' do
    deployment_data = json_fixture('files/controller/deployments.json')
    stubbed_deployment_request = stub_controller_get_deployment_request_any(deployment_data)
    stubbed_controller_create_deployment_request = stub_controller_create_deployment_request
    stub_controller_apply_credential

    file_content = File.read('test/fixtures/files/test-compose-success-without-dependencies.yml')
    encoded_content = Base64.encode64(file_content)
    stub_dockerhub_repository_any

    params = {
      project_slug: @project.slug,
      compose_file: {
        source: '/gem/tmp/dc.uffizzi-ttl.yaml',
        path: '/gem/tmp/dc.uffizzi-ttl.yaml',
        content: encoded_content,
      },
      dependencies: [],
      metadata: {},
    }

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { UffizziCore::Deployment.count } => 1,
      -> { UffizziCore::Container.count } => 3,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    assert_requested stubbed_controller_create_deployment_request
    assert_requested stubbed_deployment_request

    container_keys = [:image, :tag, :service_name, :port, :public]
    actual_containers_attributes = UffizziCore::Container.all.map { |c| c.attributes.deep_symbolize_keys.slice(*container_keys) }
    actual_template_containers_attributes = UffizziCore::Template.last
      .payload
      .deep_symbolize_keys[:containers_attributes]
      .map { |c| c.slice(*container_keys) }

    actual_app_container_attributes = actual_containers_attributes.detect { |c| c[:service_name] == 'app' }
    actual_db_container_attributes = actual_containers_attributes.detect { |c| c[:service_name] == 'db' }
    actual_nginx_container_attributes = actual_containers_attributes.detect { |c| c[:service_name] == 'nginx' }

    actual_template_app_container_attributes = actual_template_containers_attributes.detect { |c| c[:service_name] == 'app' }
    actual_template_db_container_attributes = actual_template_containers_attributes.detect { |c| c[:service_name] == 'db' }
    actual_template_nginx_container_attributes = actual_template_containers_attributes.detect { |c| c[:service_name] == 'nginx' }

    expected_app_container_attributes = {
      image: 'uffizzicloud/app',
      tag: 'latest',
      service_name: 'app',
      port: nil,
      public: false,
    }
    expected_db_container_attributes = {
      image: 'library/postgres',
      tag: 'latest',
      service_name: 'db',
      port: nil,
      public: false,
    }
    expected_nginx_container_attributes = {
      image: 'library/nginx',
      tag: '1.32',
      service_name: 'nginx',
      port: 80,
      public: true,
    }

    assert_equal expected_app_container_attributes, actual_app_container_attributes
    assert_equal expected_app_container_attributes, actual_template_app_container_attributes

    assert_equal expected_db_container_attributes, actual_db_container_attributes
    assert_equal expected_db_container_attributes, actual_template_db_container_attributes

    assert_equal expected_nginx_container_attributes, actual_nginx_container_attributes
    assert_equal expected_nginx_container_attributes, actual_template_nginx_container_attributes
  end
end
