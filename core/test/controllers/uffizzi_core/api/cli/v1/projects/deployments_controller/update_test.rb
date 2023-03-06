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
          'repository' => 'feature/#24_my_awesome_feature',
          'pull_request' => {
            'number' => '24',
          },
        },
      },
    }

    @deployment.update!(subdomain: UffizziCore::Deployment::DomainService.build_subdomain(@deployment))
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

  test '#update - update deployment created from main compose file' do
    file_content = File.read('test/fixtures/files/test-compose-success-without-dependencies.yml')
    compose_file = create(:compose_file, project: @project, added_by: @admin)
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: @template.payload)
    @deployment.update!(compose_file: compose_file)
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = attributes_for(:compose_file, :temporary, project: @project, added_by: @admin, content: encoded_content)
    stub_dockerhub_repository_any

    params = {
      project_slug: @project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
      id: @deployment[:id],
      metadata: {},
    }

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 1,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 1,
      -> { @deployment.containers.count } => 3,
    }

    assert_difference differences do
      put :update, params: params, format: :json
    end

    assert_response :success

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

  test '#update - update deployment with metadata' do
    file_content = File.read('test/fixtures/files/test-compose-success-without-dependencies.yml')
    compose_file = create(:compose_file, project: @project, added_by: @admin)
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: @template.payload)
    @deployment.update!(compose_file: compose_file)
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = attributes_for(:compose_file, :temporary, project: @project, added_by: @admin, content: encoded_content)
    2.times { stub_dockerhub_repository_any }

    params = {
      project_slug: @project.slug,
      compose_file: compose_file_attributes,
      dependencies: [],
      id: @deployment[:id],
      metadata: @metadata,
    }

    put :update, params: params, format: :json

    assert_response :success
    assert_equal(@metadata, @deployment.reload.metadata)
  end

  test '#update - update deployment created from temporary compose file' do
    file_content = File.read('test/fixtures/files/test-compose-full.yml')
    compose_file = create(:compose_file, :temporary, project: @project, added_by: @admin)
    create(:template, :compose_file_source, compose_file: compose_file, project: @project, added_by: @admin, payload: @template.payload)
    @deployment.update!(compose_file: compose_file)
    encoded_content = Base64.encode64(file_content)
    compose_file_attributes = attributes_for(:compose_file, :temporary, project: @project, added_by: @admin, content: encoded_content)
    stub_dockerhub_repository_any

    # rubocop:disable Layout/LineLength
    params = {
      project_slug: @project.slug,
      compose_file: compose_file_attributes,
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
      id: @deployment[:id],
      metadata: {},
    }
    # rubocop:enable Layout/LineLength

    differences = {
      -> { UffizziCore::ComposeFile.temporary.count } => 0,
      -> { UffizziCore::Template.with_creation_source(UffizziCore::Template.creation_source.compose_file).count } => 0,
      -> { @deployment.containers.count } => 3,
      -> { UffizziCore::HostVolumeFile.count } => 5,
      -> { UffizziCore::ConfigFile.count } => 1,
    }

    assert_difference differences do
      put :update, params: params, format: :json
    end

    assert_response :success

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
      memory_request: 125,
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
  end
end
