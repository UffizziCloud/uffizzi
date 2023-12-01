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

    @deployment.update!(subdomain: UffizziCore::Deployment::DomainService.build_subdomain(@deployment))

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
      full_image_name: "#{image}:#{target_branch}",
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
      full_image_name: "#{image}:#{target_branch}",
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
      full_image_name: "#{image}:#{target_branch}",
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
    assert_equal(deployment.creation_source, UffizziCore::Deployment.creation_source.compose_file_manual)

    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - from the existing compose file with metadata when an active deployment exists - should return an eror' do
    create(:deployment, metadata: @metadata, project: @project)

    params = { project_slug: @project.slug, compose_file: {}, dependencies: [], metadata: @metadata }

    post :create, params: params, format: :json

    assert_response :unprocessable_entity
  end

  test '#create - from the existing compose file with github_actions creation source (for self-hosted version)' do
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
      image: image,
      tag: target_branch,
      full_image_name: "#{image}:#{target_branch}",
      receive_incoming_requests: true,
      repo_attributes: repo_attributes,
    )
    template_payload = {
      containers_attributes: [container_attributes],
    }
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: template_payload)
    stub_dockerhub_repository('library', 'redis')
    creation_source = UffizziCore::Deployment.creation_source.github_actions

    params = { project_slug: @project.slug, compose_file: {}, dependencies: [], creation_source: creation_source }

    post :create, params: params, format: :json

    assert_response :success
    deployment = compose_file.deployments.first

    assert_equal(creation_source, deployment.creation_source)

    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - from the existing compose file when credentials are removed' do
    create_namespace_request = stub_create_namespace_request
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
      full_image_name: "#{image}:#{target_branch}",
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
    assert_not_requested(create_namespace_request)
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
      full_image_name: "#{image}:#{target_branch}",
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
    stubbed_namespace_request = stub_controller_get_namespace_request_any(deployment_data)
    stubbed_controller_create_name_request = stub_create_namespace_request
    stub_controller_apply_credential

    compose_file_name = 'test-compose-full.yml'
    file_content = File.read("test/fixtures/files/#{compose_file_name}")
    encoded_content = Base64.encode64(file_content)
    stub_dockerhub_repository_any

    # rubocop:disable Layout/LineLength
    params = {
      project_slug: @project.slug,
      compose_file: {
        source: "/gem/tmp/#{compose_file_name}",
        path: "/gem/tmp/#{compose_file_name}",
        content: encoded_content,
      },
      dependencies: [
        {
          content: "ZGF0YQ1==\n",
          is_file: false,
          path: '/gem/tmp/some_app_dir',
          source: './some_app_dir',
          use_kind: 'volume',
        },
        {
          content: "ZGF0YQ2==\n",
          is_file: true,
          path: '/gem/tmp/files/some_app_file',
          source: './files/some_app_file',
          use_kind: 'volume',
        },
        {
          content: "ZGF0YQ3==\n",
          is_file: false,
          path: '/gem/tmp/some_db_dir',
          source: './some_db_dir',
          use_kind: 'volume',
        },
        {
          content: "ZGF0YQ4==\n",
          is_file: true,
          path: '/gem/tmp/some_db_file',
          source: './some_db_file',
          use_kind: 'volume',
        },
        {
          content: "ZGF0YQ==\n",
          is_file: false,
          path: '/gem/tmp',
          source: './',
          use_kind: 'volume',
        },
        {
          content: "S0VZPXZhbHVl\n",
          path: 'env_files/env_file.env',
          source: 'env_files/env_file.env',
          use_kind: 'config_map',
        },
        {
          content: "UE9TVEdSRVNfVVNFUj1wb3N0Z3JlcyBQT1NUR1JFU19QQVNTV09SRD1wb3N0\nZ3Jlcw==\n",
          path: 'local.env',
          source: 'local.env',
          use_kind: 'config_map',
        },
        {
          content: "c2VydmVyIHsgbGlzdGVuICAgICAgIDg4ODg7IHNlcnZlcl9uYW1lICBsb2Nh\nbGhvc3Q7IGxvY2F0aW9uIC8geyBwcm94eV9wYXNzICAgICAgaHR0cDovLzEy\nNy4wLjAuMTo4MDg4LzsgfSBsb2NhdGlvbiAvdm90ZS8geyBwcm94eV9wYXNz\nICAgICAgaHR0cDovLzEyNy4wLjAuMTo4ODg4LzsgfSB9\n",
          path: 'config_files/config_file.conf',
          source: 'config_files/config_file.conf',
          use_kind: 'config_map',
        },
        {
          content: "c2VydmVyIHsgbGlzdGVuICAgICAgIDgwODA7IHNlcnZlcl9uYW1lICBsb2Nh\nbGhvc3Q7IGxvY2F0aW9uIC8geyBwcm94eV9wYXNzICAgICAgaHR0cDovLzEy\nNy4wLjAuMTo4MDg4LzsgfSBsb2NhdGlvbiAvdm90ZS8geyBwcm94eV9wYXNz\nICAgICAgaHR0cDovLzEyNy4wLjAuMTo4ODg4LzsgfSB9\n",
          path: 'app.conf',
          source: 'app.conf',
          use_kind: 'config_map',
        },
      ],
      metadata: {},
    }
    # rubocop:enable Layout/LineLength

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { UffizziCore::Deployment.count } => 1,
      -> { UffizziCore::Container.count } => 3,
      -> { UffizziCore::HostVolumeFile.count } => 5,
      -> { UffizziCore::ConfigFile.count } => 1,
      -> { UffizziCore::Repo.count } => 3,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    assert_requested(stubbed_controller_create_name_request)
    assert_requested(stubbed_namespace_request)

    default_container_attributes = {
      image: nil,
      tag: nil,
      service_name: nil,
      variables: [],
      public: false,
      port: nil,
      state: 'active',
      continuously_deploy: 'enabled',
      kind: 'user',
      target_port: nil,
      controller_name: nil,
      receive_incoming_requests: false,
      memory_request: 125 / UffizziCore::Container::REQUEST_MEMORY_RATIO,
      memory_limit: 125,
      secret_variables: [],
      entrypoint: nil,
      command: nil,
      healthcheck: {},
      volumes: [],
      additional_subdomains: [],
      source: nil,
    }

    app_container_attributes = {
      image: 'uffizzicloud/app',
      tag: 'latest',
      service_name: 'app',
      volumes: [
        {
          type: 'host',
          source: './some_app_dir',
          target: '/var/app/some_dir',
          read_only: false,
        },
        {
          type: 'host',
          source: './files/some_app_file',
          target: '/var/app/some_app_files',
          read_only: false,
        },
        {
          type: 'host',
          source: './',
          target: '/var/entire_app',
          read_only: false,
        },
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
      variables: [
        {
          name: 'POSTGRES_USER',
          value: 'postgres POSTGRES_PASSWORD=postgres',
        },
        {
          name: 'KEY',
          value: 'value',
        },
      ],
    }

    db_container_attributes = {
      image: 'library/postgres',
      tag: 'latest',
      service_name: 'db',
      volumes: [
        {
          type: 'host',
          source: './some_app_dir',
          target: '/var/db/some_dir_2',
          read_only: false,
        },
        {
          type: 'host',
          source: './some_db_dir',
          target: '/var/db/some_dir_3',
          read_only: false,
        },
        {
          type: 'host',
          source: './some_db_file',
          target: '/var/db/some_db_files',
          read_only: false,
        },
        {
          type: 'named',
          source: 'db_share',
          target: '/some_db_share',
          read_only: true,
        },
      ],
    }

    nginx_container_attributes = {
      image: 'library/nginx',
      tag: '1.32',
      service_name: 'nginx',
      port: 80,
      target_port: 80,
      public: true,
      receive_incoming_requests: true,
    }

    expected_app_container_attributes = default_container_attributes.merge(app_container_attributes)
    expected_db_container_attributes = default_container_attributes.merge(db_container_attributes)
    expected_nginx_container_attributes = default_container_attributes.merge(nginx_container_attributes)

    exclude_params = [:state, :source, :kind, :target_port, :controller_name]
    expected_template_app_container_attributes = default_container_attributes.merge(app_container_attributes).without(exclude_params)
    expected_template_db_container_attributes = default_container_attributes.merge(db_container_attributes).without(exclude_params)
    expected_template_nginx_container_attributes = default_container_attributes.merge(nginx_container_attributes).without(exclude_params)

    container_keys = default_container_attributes.keys
    deployment = UffizziCore::Deployment.last
    actual_containers_attributes = deployment.containers.map { |c| c.attributes.deep_symbolize_keys.slice(*container_keys) }
    actual_template_containers_attributes = deployment.compose_file.template.payload
      .deep_symbolize_keys[:containers_attributes]
      .map { |c| c.slice(*container_keys) }

    actual_app_container_attributes = actual_containers_attributes.detect { |c| c[:service_name] == 'app' }
    actual_db_container_attributes = actual_containers_attributes.detect { |c| c[:service_name] == 'db' }
    actual_nginx_container_attributes = actual_containers_attributes.detect { |c| c[:service_name] == 'nginx' }

    actual_template_app_container_attributes = actual_template_containers_attributes.detect { |c| c[:service_name] == 'app' }
    actual_template_db_container_attributes = actual_template_containers_attributes.detect { |c| c[:service_name] == 'db' }
    actual_template_nginx_container_attributes = actual_template_containers_attributes.detect { |c| c[:service_name] == 'nginx' }

    assert_equal expected_app_container_attributes, actual_app_container_attributes
    assert_equal expected_template_app_container_attributes, actual_template_app_container_attributes

    assert_equal expected_db_container_attributes, actual_db_container_attributes
    assert_equal expected_template_db_container_attributes, actual_template_db_container_attributes

    assert_equal expected_nginx_container_attributes, actual_nginx_container_attributes
    assert_equal expected_template_nginx_container_attributes, actual_template_nginx_container_attributes

    actual_host_volume_file_paths = UffizziCore::HostVolumeFile.pluck(:path)
    expected_host_volume_file_paths = params[:dependencies].select { |d| d[:use_kind] == 'volume' }.pluck(:path)

    assert_equal expected_host_volume_file_paths.sort, actual_host_volume_file_paths.sort

    actual_host_volume_file_sources = UffizziCore::HostVolumeFile.pluck(:source)
    expected_host_volume_file_sources = params[:dependencies]
      .select { |d| d[:use_kind] == 'volume' }
      .pluck(:source)
      .map { |s| "#{compose_file_name}/#{s}" }

    assert_equal expected_host_volume_file_sources.sort, actual_host_volume_file_sources.sort

    actual_host_volume_file_count_which_is_file = UffizziCore::HostVolumeFile.where(is_file: true).count

    assert_equal(2, actual_host_volume_file_count_which_is_file)
  end

  test '#create - file with local host volume when same host volume file exists' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!

    stub_dockerhub_login
    stub_dockerhub_repository('library', 'nginx')
    create(:credential, :docker_hub, account: @admin.personal_account)
    compose_file_content = File.read('test/fixtures/files/uffizzi-compose-with-host-volumes.yml')
    encoded_compose_file_content = Base64.encode64(compose_file_content)
    host_volume_content = Base64.encode64(File.binread('test/fixtures/files/file.tar.gz'))

    compose_file_params = {
      source: '/gem/tmp/dc.uffizzi-nginx.yaml',
      path: '/gem/tmp/dc.uffizzi-nginx.yaml',
      content: encoded_compose_file_content,
    }

    dependency = {
      path: '/gem/tmp/share_dir',
      source: './share_dir',
      content: host_volume_content,
      use_kind: UffizziCore::ComposeFile::DependenciesService::DEPENDENCY_VOLUME_USE_KIND,
      is_file: false,
    }

    compose_file = create(:compose_file, project: @project, added_by: @admin, content: encoded_compose_file_content)
    create(:host_volume_file, path: dependency[:path],
                              source: 'dc.uffizzi-nginx.yaml/./share_dir',
                              payload: Base64.decode64(dependency[:content]),
                              is_file: false,
                              project: @project,
                              compose_file: compose_file)

    params = { project_slug: @project.slug, compose_file: compose_file_params, dependencies: [dependency] }

    differences = {
      -> { UffizziCore::Container.count } => 1,
      -> { UffizziCore::ContainerHostVolumeFile.count } => 1,
      -> { UffizziCore::HostVolumeFile.count } => 0,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success

    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - from amazon image with credentials' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
    registry_url = 'https://323707565364.dkr.ecr.us-east-1.amazonaws.com'
    stub_docker_registry_manifests(registry_url, 'test-compose', 'latest')

    sign_in @admin

    project = create(:project, :with_members, account: @account, members: [@admin])
    create(:credential, :amazon, :active, account: @account, registry_url: registry_url)

    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    file_content = File.read('test/fixtures/files/uffizzi-compose-amazon.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = base_attributes.merge(content: encoded_content, repository_id: nil)

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { UffizziCore::Container.count } => 1,
    }

    params = {
      project_slug: project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
      metadata: {},
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - compose file with jfrog docker registry with auth' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
    stub_docker_registry_manifests('https://elnealo.jfrog.io', 'uffizzi-test-docker/webhook-test-app', 'latest')

    compose_file_content = File.read('test/fixtures/files/test-compose-success-jfrog.yml')
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

  test '#create - from azure image with credentials' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
    registry_url = 'account.azurecr.io/nginx:latest'
    stub_docker_registry_manifests(registry_url, 'test-compose', 'latest')

    sign_in @admin

    project = create(:project, :with_members, account: @account, members: [@admin])
    create(:credential, :azure, :active, account: @account, registry_url: registry_url)

    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    file_content = File.read('test/fixtures/files/uffizzi-compose-azure.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = base_attributes.merge(content: encoded_content, repository_id: nil)

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { UffizziCore::Container.count } => 1,
    }

    params = {
      project_slug: project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
      metadata: {},
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - from google(gcr) image with credentials' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
    registry_url = 'gcr.io/project1/test-compose:latest'
    stub_docker_registry_manifests(registry_url, 'test-compose', 'latest')

    sign_in @admin

    project = create(:project, :with_members, account: @account, members: [@admin])
    create(:credential, :google, :active, account: @account, registry_url: registry_url)

    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    file_content = File.read('test/fixtures/files/uffizzi-compose-google.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = base_attributes.merge(content: encoded_content, repository_id: nil)

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { UffizziCore::Container.count } => 1,
    }

    params = {
      project_slug: project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
      metadata: {},
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - from ghcr image with credentials' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
    registry_url = 'ghcr.io/project1/test-compose:latest'
    stub_docker_registry_manifests(registry_url, 'test-compose', 'latest')

    sign_in @admin

    project = create(:project, :with_members, account: @account, members: [@admin])
    create(:credential, :github_container_registry, :active, account: @account, registry_url: registry_url)

    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    file_content = File.read('test/fixtures/files/uffizzi-compose-ghcr.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = base_attributes.merge(content: encoded_content, repository_id: nil)

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { UffizziCore::Container.count } => 1,
    }

    params = {
      project_slug: project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
      metadata: {},
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#create - from dockerhub image with credentials' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
    registry_url = 'project1/test-compose:latest'
    stub_docker_registry_manifests(registry_url, 'test-compose', 'latest')
    stubbed_dockerhub_login = stub_dockerhub_login
    stub_dockerhub_repository('project1', 'test-compose')

    sign_in @admin

    project = create(:project, :with_members, account: @account, members: [@admin])
    create(:credential, :docker_hub, :active, account: @account, registry_url: registry_url)

    base_attributes = attributes_for(:compose_file).slice(:source, :path)
    file_content = File.read('test/fixtures/files/uffizzi-compose-dockerhub.yml')
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = base_attributes.merge(content: encoded_content, repository_id: nil)

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { UffizziCore::Container.count } => 1,
    }

    params = {
      project_slug: project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
      metadata: {},
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response :success
    assert_requested stubbed_dockerhub_login, times: 2
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end
end
