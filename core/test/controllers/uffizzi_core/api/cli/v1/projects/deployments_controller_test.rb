# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::DeploymentsControllerTest < ActionController::TestCase
  setup do
    @admin = create(:user, :with_organizational_account)
    @account = @admin.organizational_account
    @project = create(:project, :with_members, account: @admin.organizational_account, members: [@admin])
    @deployment = create(:deployment, project: @project, state: UffizziCore::Deployment::STATE_ACTIVE)

    @deployment.update!(subdomain: UffizziCore::DeploymentService.build_subdomain(@deployment))
    @credential = create(:credential, :github, :active, account: @account, provider_ref: generate(:number))

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
    @template = create(:template, :compose_file_source, compose_file: @compose_file, project: @project, added_by: @admin,
                                                        payload: template_payload)

    sign_in @admin
  end

  test '#index' do
    create(:deployment, project: @project, state: UffizziCore::Deployment::STATE_ACTIVE,
                        creation_source: UffizziCore::Deployment.creation_source.continuous_preview)

    params = { project_slug: @project.slug }

    get :index, params: params, format: :json

    assert_response :success
  end

  test '#show' do
    params = { project_slug: @project.slug, id: @deployment.id }

    get :show, params: params, format: :json

    assert_response :success
  end

  test '#create - from the existing compose file' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!

    create(:credential, :docker_hub, account: @admin.organizational_account)
    file_content = File.read('test/fixtures/files/test-compose-success.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file = create(:compose_file, project: @project, added_by: @admin, content: encoded_content)
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

    params = { project_slug: @project.slug, compose_file: {}, dependencies: [] }

    differences = {
      -> { UffizziCore::Deployment.active.count } => 1,
      -> { UffizziCore::Repo::Github.count } => 1,
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
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)

    params = { project_slug: @project.slug, compose_file: {}, dependencies: [] }

    differences = {
      -> { UffizziCore::Deployment.active.count } => 0,
      -> { UffizziCore::Repo::Github.count } => 0,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :unprocessable_entity
    assert_not_requested(create_deployment_request)
  end

  test '#create - from the existing compose file - when the file is invalid' do
    create(:credential, :github, account: @admin.organizational_account)
    compose_file = create(:compose_file, :invalid_file, project: @project, added_by: @admin)
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
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)

    params = { project_slug: @project.slug, compose_file: {}, dependencies: [] }

    differences = {
      -> { UffizziCore::Deployment.active.count } => 0,
      -> { UffizziCore::Repo::Github.count } => 0,
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

  test '#update - update deployment created from main compose file' do
    file_content = File.read('test/fixtures/files/test-compose-success-without-dependencies.yml')
    compose_file = create(:compose_file, project: @project, added_by: @admin)
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: @template.payload)
    @deployment.update!(compose_file: compose_file)
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = attributes_for(:compose_file, :temporary, project: @project, added_by: @admin, content: encoded_content)
    create(:credential, :docker_hub, account: @admin.organizational_account)

    params = {
      project_slug: @project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
      id: @deployment[:id],
    }

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { @deployment.containers.count } => 1,
    }

    assert_difference differences do
      put :update, params: params, format: :json
    end

    assert_response :success
  end

  test '#update - update deployment created from temporary compose file' do
    file_content = File.read('test/fixtures/files/test-compose-success-without-dependencies.yml')
    compose_file = create(:compose_file, :temporary, project: @project, added_by: @admin)
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: @template.payload)
    @deployment.update!(compose_file: compose_file)
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = attributes_for(:compose_file, :temporary, project: @project, added_by: @admin, content: encoded_content)
    create(:credential, :docker_hub, account: @admin.organizational_account)

    params = {
      project_slug: @project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
      id: @deployment[:id],
    }

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 0,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 0,
      -> { @deployment.containers.count } => 1,
    }

    assert_difference differences do
      put :update, params: params, format: :json
    end

    assert_response :success
  end

  test '#deploy_containers' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!

    stub_dockerhub_login
    repo1 = create(:repo, :docker_hub, project: @project)
    repo2 = create(:repo, :docker_hub, project: @project)

    create(:container, :with_public_port, deployment: @deployment, repo: repo1)
    create(:container, :with_public_port, deployment: @deployment, repo: repo2)

    params = { project_slug: @project.slug, id: @deployment.id }

    post :deploy_containers, params: params, format: :json

    assert_response :success
    assert { UffizziCore::Deployment::DeployContainersJob.jobs.size == 1 }

    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#deploy_containers if deployment has not created yet' do
    UffizziCore::ControllerService.expects(:deployment_exists?).returns(false)
    params = { project_slug: @project.slug, id: @deployment.id }

    assert_raises UffizziCore::DeploymentNotFoundError do
      post :deploy_containers, params: params, format: :json
    end
  end

  test '#deploy_containers create a new docker hub activity item' do
    UffizziCore::ControllerService.expects(:deployment_exists?).returns(true)

    webhooks_data = json_fixture('files/dockerhub/webhooks/push/event_data.json')
    digest_data = json_fixture('files/dockerhub/digest.json')
    deployment_containers_data = json_fixture('files/controller/deployment_containers.json')
    deployment_data = json_fixture('files/controller/deployments.json')

    stubbed_deployment_request = stub_controller_get_deployment_request(@deployment, deployment_data)
    stubbed_containers_request = stub_controller_containers_request(@deployment, deployment_containers_data)
    stubbed_deploy_containers_request = stub_deploy_containers_request(@deployment)
    stubbed_dockerhub_login = stub_dockerhub_login

    params = { project_slug: @project.slug, id: @deployment.id }

    namespace, name = webhooks_data[:repository][:repo_name].split('/')

    repo = create(:repo,
                  :docker_hub,
                  project: @project,
                  namespace: namespace,
                  name: name)

    container = create(
      :container,
      :continuously_deploy_enabled,
      deployment: @deployment,
      repo: repo,
      image: webhooks_data[:repository][:repo_name],
      tag: webhooks_data[:push_data][:tag],
      controller_name: deployment_containers_data.first[:spec][:containers].first[:controllerName],
    )

    create(:credential, :docker_hub, account: @account)

    stubbed_digest_auth = stub_dockerhub_auth_for_digest(container.image)
    stubbed_digest = stub_dockerhub_get_digest(container.image, container.tag, digest_data)

    post :deploy_containers, params: params, format: :json

    assert_requested stubbed_digest
    assert_requested stubbed_digest_auth
    assert_requested stubbed_dockerhub_login
    assert_requested stubbed_deploy_containers_request
    assert_requested stubbed_containers_request
    assert_requested stubbed_deployment_request
    assert { UffizziCore::Deployment::DeployContainersJob.jobs.empty? }
    assert { UffizziCore::ActivityItem::Docker.count == 1 }
  end

  test '#deploy_containers skip activity item creation if existing has not finished yet' do
    UffizziCore::ControllerService.expects(:deployment_exists?).returns(true)

    webhooks_data = json_fixture('files/dockerhub/webhooks/push/event_data.json')
    digest_data = json_fixture('files/dockerhub/digest.json')
    deployment_containers_data = json_fixture('files/controller/deployment_containers.json')
    deployment_data = json_fixture('files/controller/deployments.json')

    namespace, name = webhooks_data[:repository][:repo_name].split('/')

    repo = create(:repo,
                  :docker_hub,
                  project: @project,
                  namespace: namespace,
                  name: name)

    container = create(
      :container,
      :continuously_deploy_enabled,
      deployment: @deployment,
      repo: repo,
      image: webhooks_data[:repository][:repo_name],
      tag: webhooks_data[:push_data][:tag],
      controller_name: deployment_containers_data.first[:spec][:containers].first[:controllerName],
    )

    create(:activity_item,
           :docker,
           :with_building_event,
           namespace: repo.namespace,
           name: repo.name,
           tag: container.tag,
           container: container,
           deployment: @deployment)

    stubbed_deployment_request = stub_controller_get_deployment_request(@deployment, deployment_data)
    stubbed_containers_request = stub_controller_containers_request(@deployment, deployment_containers_data)
    stubbed_deploy_containers_request = stub_deploy_containers_request(@deployment)
    stubbed_dockerhub_login = stub_dockerhub_login

    params = { project_slug: @project.slug, id: @deployment.id }

    create(:credential, :docker_hub, account: @account)

    stubbed_digest_auth = stub_dockerhub_auth_for_digest(container.image)
    stubbed_digest = stub_dockerhub_get_digest(container.image, container.tag, digest_data)

    post :deploy_containers, params: params, format: :json

    assert_requested stubbed_digest
    assert_requested stubbed_digest_auth
    assert_requested stubbed_dockerhub_login
    assert_requested stubbed_deploy_containers_request
    assert_requested stubbed_containers_request
    assert_requested stubbed_deployment_request
    assert { UffizziCore::Deployment::DeployContainersJob.jobs.empty? }
    assert { UffizziCore::ActivityItem::Docker.count == 1 }
  end

  test '#deploy_containers create a new activity item creation if existing has finished' do
    UffizziCore::ControllerService.expects(:deployment_exists?).returns(true)
    webhooks_data = json_fixture('files/dockerhub/webhooks/push/event_data.json')
    digest_data = json_fixture('files/dockerhub/digest.json')
    deployment_containers_data = json_fixture('files/controller/deployment_containers.json')
    deployment_data = json_fixture('files/controller/deployments.json')

    namespace, name = webhooks_data[:repository][:repo_name].split('/')

    repo = create(:repo,
                  :docker_hub,
                  project: @project,
                  namespace: namespace,
                  name: name)

    container = create(
      :container,
      :continuously_deploy_enabled,
      deployment: @deployment,
      repo: repo,
      image: webhooks_data[:repository][:repo_name],
      tag: webhooks_data[:push_data][:tag],
      controller_name: deployment_containers_data.first[:spec][:containers].first[:controllerName],
    )

    create(:activity_item,
           :docker,
           :with_deployed_event,
           namespace: repo.namespace,
           name: repo.name,
           tag: container.tag,
           container: container,
           deployment: @deployment)

    stubbed_deployment_request = stub_controller_get_deployment_request(@deployment, deployment_data)
    stubbed_containers_request = stub_controller_containers_request(@deployment, deployment_containers_data)
    stubbed_deploy_containers_request = stub_deploy_containers_request(@deployment)
    stubbed_dockerhub_login = stub_dockerhub_login

    params = { project_slug: @project.slug, id: @deployment.id }

    create(:credential, :docker_hub, account: @account)

    stubbed_digest_auth = stub_dockerhub_auth_for_digest(container.image)
    stubbed_digest = stub_dockerhub_get_digest(container.image, container.tag, digest_data)

    post :deploy_containers, params: params, format: :json

    assert_requested stubbed_digest
    assert_requested stubbed_digest_auth
    assert_requested stubbed_dockerhub_login
    assert_requested stubbed_deploy_containers_request
    assert_requested stubbed_containers_request
    assert_requested stubbed_deployment_request
    assert { UffizziCore::Deployment::DeployContainersJob.jobs.empty? }
    assert { UffizziCore::ActivityItem::Docker.count == 2 }
  end

  test '#deploy_containers create a new activity item creation without credential' do
    UffizziCore::ControllerService.expects(:deployment_exists?).returns(true)
    webhooks_data = json_fixture('files/dockerhub/webhooks/push/event_data.json')
    deployment_containers_data = json_fixture('files/controller/deployment_containers.json')
    deployment_data = json_fixture('files/controller/deployments.json')

    namespace, name = webhooks_data[:repository][:repo_name].split('/')

    repo = create(:repo,
                  :docker_hub,
                  project: @project,
                  namespace: namespace,
                  name: name)

    container = create(
      :container,
      :continuously_deploy_enabled,
      :with_named_volume,
      deployment: @deployment,
      repo: repo,
      image: webhooks_data[:repository][:repo_name],
      tag: webhooks_data[:push_data][:tag],
      controller_name: deployment_containers_data.first[:spec][:containers].first[:controllerName],
    )

    create(:activity_item,
           :docker,
           :with_deployed_event,
           namespace: repo.namespace,
           name: repo.name,
           tag: container.tag,
           container: container,
           deployment: @deployment)

    stubbed_deployment_request = stub_controller_get_deployment_request(@deployment, deployment_data)
    stubbed_containers_request = stub_controller_containers_request(@deployment, deployment_containers_data)
    stubbed_deploy_containers_request = stub_deploy_containers_request(@deployment)

    params = { project_slug: @project.slug, id: @deployment.id }

    post :deploy_containers, params: params, format: :json

    assert { UffizziCore::ActivityItem.last.digest.nil? }
    assert_requested stubbed_deploy_containers_request
    assert_requested stubbed_containers_request
    assert_requested stubbed_deployment_request
    assert { UffizziCore::Deployment::DeployContainersJob.jobs.empty? }
    assert { UffizziCore::ActivityItem::Docker.count == 2 }
  end

  test '#destroy' do
    stubbed_request = stub_delete_controller_deployment_request(@deployment)
    container = create(:container, :with_public_port, deployment: @deployment)

    differences = {
      -> { UffizziCore::Deployment.active.count } => -1,
    }

    params = {
      project_slug: @project.slug,
      id: @deployment.id,
    }

    assert_difference differences do
      delete :destroy, params: params, format: :json
    end

    assert_requested stubbed_request
    assert { container.reload.disabled? }

    assert_response :success
  end
end
