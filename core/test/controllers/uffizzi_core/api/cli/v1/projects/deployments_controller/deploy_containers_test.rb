# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::DeploymentsControllerTest < ActionController::TestCase
  setup do
    @admin = create(:user, :with_personal_account)
    @account = @admin.personal_account
    @project = create(:project, :with_members, account: @admin.personal_account, members: [@admin])
    @deployment = create(:deployment, project: @project, state: UffizziCore::Deployment::STATE_ACTIVE)

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

  test '#deploy_containers create a new activity items' do
    metadata = {
      'labels' => {
        'github' => {
          'repository' => 'feature/#24_my_awesome_feature',
          'event' => {
            'number' => '24',
          },
        },
      },
    }
    @deployment.update!(metadata: metadata)

    UffizziCore::ControllerService.expects(:deployment_exists?).at_least(1).returns(true)

    digest_data = json_fixture('files/dockerhub/digest.json')
    deployment_containers_data = json_fixture('files/controller/deployment_containers.json')
    deployment_data = json_fixture('files/controller/deployments.json')

    stubbed_deployment_request = stub_controller_get_deployment_request(@deployment, deployment_data)
    stubbed_containers_request = stub_controller_containers_request(@deployment, deployment_containers_data)
    stubbed_dockerhub_login = stub_dockerhub_login

    compose_file_name = 'test-compose-full.yml'
    file_content = File.read("test/fixtures/files/#{compose_file_name}")
    encoded_content = Base64.encode64(file_content)
    compose_file = create(:compose_file, content: encoded_content, repository_id: nil, branch: nil, project: @project)
    @deployment.update!(compose_file: compose_file)

    controller_name = deployment_containers_data.first[:spec][:containers].first[:controllerName]
    app_name = 'app'
    app_namespace = 'uffizzicloud'
    nginx_name = 'nginx'
    nginx_namespace = 'library'
    container_version = '1'

    host_volume_file_attrs_app_dir = {
      type: 'host',
      source: './some_app_dir',
      target: '/var/app/some_dir',
      read_only: false,
    }

    host_volume_file_attrs_app_dir2 = {
      type: 'host',
      source: './',
      target: '/var/entire_app',
      read_only: false,
    }

    host_volume_file_attrs_app_file = {
      type: 'host',
      source: './files/some_app_file',
      target: '/var/app/some_app_files',
      read_only: false,
    }

    container_app_attrs = {
      controller_name: controller_name,
      service_name: app_name,
      image: "#{app_namespace}/#{app_name}",
      tag: 'latest',
      volumes: [
        host_volume_file_attrs_app_dir,
        host_volume_file_attrs_app_file,
        host_volume_file_attrs_app_dir2,
        {
          type: 'named',
          source: 'app_share',
          target: '/some_app_share',
          read_only: true,
        },
        {
          type: 'anonymous',
          source: '/some_anonymous_dir',
          target: nil,
          read_only: false,
        },
      ],
    }

    container_nginx_attrs = {
      controller_name: controller_name,
      service_name: nginx_name,
      image: "#{nginx_namespace}/#{nginx_name}",
      tag: '1.32',
      public: true,
      port: 80,
      target_port: 80,
    }

    host_volume_file_app_dir_params = {
      path: host_volume_file_attrs_app_dir[:source],
      source: "#{compose_file_name}/#{host_volume_file_attrs_app_dir[:source]}",
      payload: 'some_app_dir_data',
      is_file: false,
      project: @project,
      compose_file: compose_file,
    }

    host_volume_file_app_dir2_params = {
      path: host_volume_file_attrs_app_dir2[:source],
      source: "#{compose_file_name}/#{host_volume_file_attrs_app_dir2[:source]}",
      payload: 'some_app_dir_data',
      is_file: false,
      project: @project,
      compose_file: compose_file,
    }

    host_volume_file_app_file_params = {
      path: host_volume_file_attrs_app_file[:source],
      source: "#{compose_file_name}/#{host_volume_file_attrs_app_file[:source]}",
      payload: 'some_app_file_data',
      is_file: true,
      project: @project,
      compose_file: compose_file,
    }

    docker_hub_credential = create(:credential, :docker_hub, account: @account)
    app_repo = create(:repo, :docker_hub, project: @project, namespace: app_namespace, name: app_name)
    nginx_repo = create(:repo, :docker_hub, project: @project, namespace: nginx_namespace, name: nginx_name)
    host_volume_file_app_dir = create(:host_volume_file, **host_volume_file_app_dir_params)
    host_volume_file_app_dir2 = create(:host_volume_file, **host_volume_file_app_dir2_params)
    host_volume_file_app_file = create(:host_volume_file, **host_volume_file_app_file_params)
    app_container = create(:container, :continuously_deploy_enabled,
                           **{ deployment: @deployment, repo: app_repo }.merge(container_app_attrs))
    nginx_container = create(:container, :continuously_deploy_enabled,
                             **{ deployment: @deployment, repo: nginx_repo }.merge(container_nginx_attrs))

    container_host_volume_files_app_dir = create(:container_host_volume_file, container: app_container,
                                                                              host_volume_file: host_volume_file_app_dir,
                                                                              source_path: host_volume_file_attrs_app_dir[:source])
    container_host_volume_files_app_dir2 = create(:container_host_volume_file, container: app_container,
                                                                               host_volume_file: host_volume_file_app_dir2,
                                                                               source_path: host_volume_file_attrs_app_dir2[:source])
    container_host_volume_files_app_file = create(:container_host_volume_file, container: app_container,
                                                                               host_volume_file: host_volume_file_app_file,
                                                                               source_path: host_volume_file_attrs_app_file[:source])

    app_config_file = create(:config_file, :compose_file_source, project: @project, payload: 'data', filename: 'config_file.conf')
    app_container_config_file = create(:container_config_file, container: app_container, config_file: app_config_file)

    stubbed_digest_auth_app = stub_dockerhub_auth_for_digest(app_container.image)
    stubbed_digest_auth_nginx = stub_dockerhub_auth_for_digest(nginx_container.image)
    stubbed_digest_app = stub_dockerhub_get_digest(app_container.image, app_container.tag, digest_data)
    stubbed_digest_nginx = stub_dockerhub_get_digest(nginx_container.image, nginx_container.tag, digest_data)

    expected_default_container_params = {
      secret_variables: [],
      memory_limit: nil,
      memory_request: nil,
      entrypoint: nil,
      command: nil,
      port: nil,
      target_port: nil,
      public: false,
      receive_incoming_requests: false,
      healthcheck: {},
      volumes: nil,
      container_config_files: [],
      additional_subdomains: [],
      container_host_volume_files: [],
      version: container_version,
    }

    expected_app_container_attrs = {
      id: app_container.id,
      kind: app_container.kind,
      variables: [
        {
          name: 'UFFIZZI_URL',
          value: "https://#{@deployment.preview_url}",
        },
        {
          name: 'UFFIZZI_DOMAIN',
          value: @deployment.preview_url,
        },
        {
          name: 'UFFIZZI_PREDICTABLE_URL',
          value: '',
        },
      ],
      container_host_volume_files: [
        {
          host_volume_file_id: host_volume_file_app_dir.id,
          source_path: container_host_volume_files_app_dir.source_path,
        },
        {
          host_volume_file_id: host_volume_file_app_dir2.id,
          source_path: container_host_volume_files_app_dir2.source_path,
        },
        {
          host_volume_file_id: host_volume_file_app_file.id,
          source_path: container_host_volume_files_app_file.source_path,
        },
      ],
      container_config_files: [
        {
          mount_path: app_container_config_file.mount_path,
          config_file: {
            id: app_config_file.id,
            filename: app_config_file.filename,
            kind: app_config_file.kind,
            payload: app_config_file.payload,
          },
        },
      ],
    }

    expected_nginx_container_attrs = {
      id: nginx_container.id,
      kind: nginx_container.kind,
      variables: [
        {
          name: 'UFFIZZI_URL',
          value: "https://#{@deployment.preview_url}",
        },
        {
          name: 'UFFIZZI_DOMAIN',
          value: @deployment.preview_url,
        },
        {
          name: 'PORT',
          value: '80',
        },
        {
          name: 'UFFIZZI_PREDICTABLE_URL',
          value: '',
        },
      ],
    }

    expected_app_container = expected_default_container_params
      .merge(expected_app_container_attrs)
      .merge(container_app_attrs)

    expected_nginx_container = expected_default_container_params
      .merge(expected_nginx_container_attrs)
      .merge(container_nginx_attrs)

    expected_request_container_to_controller = {
      containers: [
        expected_app_container,
        expected_nginx_container,
      ],
      credentials: [{ id: docker_hub_credential.id }, { id: @credential.id }],
      deployment_url: @deployment.preview_url,
      compose_file: { source_kind: 'local' },
      host_volume_files: [
        {
          id: host_volume_file_app_dir.id,
          source: host_volume_file_app_dir_params[:source],
          path: host_volume_file_app_dir_params[:path],
          payload: Base64.encode64(host_volume_file_app_dir_params[:payload]),
          is_file: host_volume_file_app_dir_params[:is_file],
        },
        {
          id: host_volume_file_app_dir2.id,
          source: host_volume_file_app_dir2_params[:source],
          path: host_volume_file_app_dir2_params[:path],
          payload: Base64.encode64(host_volume_file_app_dir2_params[:payload]),
          is_file: host_volume_file_app_dir2_params[:is_file],
        },
        {
          id: host_volume_file_app_file.id,
          source: host_volume_file_app_file_params[:source],
          path: host_volume_file_app_file_params[:path],
          payload: Base64.encode64(host_volume_file_app_file_params[:payload]),
          is_file: host_volume_file_app_file_params[:is_file],
        },
      ],
    }

    expected_request_config_file_to_controller = {
      config_file: {
        id: app_config_file.id,
        filename: app_config_file.filename,
        kind: app_config_file.kind,
        payload: app_config_file.payload,
      },
    }

    stub_apply_config_file_request_with_expected(@deployment, app_config_file, expected_request_config_file_to_controller)
    stubbed_deploy_containers_request = stub_deploy_containers_request_with_expected(@deployment, expected_request_container_to_controller)

    params = { project_slug: @project.slug, id: @deployment.id }

    UffizziCore::ContainerService.stub(:generate_version, container_version) do
      post :deploy_containers, params: params, format: :json
    end

    assert_requested stubbed_deploy_containers_request
    assert_requested stubbed_digest_app
    assert_requested stubbed_digest_nginx
    assert_requested stubbed_digest_auth_app
    assert_requested stubbed_digest_auth_nginx
    assert_requested stubbed_dockerhub_login, times: 2
    assert_requested stubbed_containers_request, times: 2
    assert_requested stubbed_deployment_request, times: 2
    assert { UffizziCore::Deployment::DeployContainersJob.jobs.empty? }
    assert { UffizziCore::ActivityItem::Docker.count == 2 }
  end
end
