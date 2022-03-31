# frozen_string_literal: true

require 'test_helper'

class UffizziCore::ActivityItemServiceTest < ActiveSupport::TestCase
  setup do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all

    @user = create(:user, :with_organizational_account)
    @project = create(:project, account: @user.organizational_account)
    @deployment = create(:deployment, project: @project)
  end

  teardown do
    Sidekiq::Testing.inline!
  end

  test '#manage_deploy_activity_item - pending resource availability' do
    repo = create(:repo, :docker_hub, project: @project)
    container = create(:container, :with_public_port, deployment: @deployment, repo: repo, image: 'library/nginx')
    namespace, name = container.image.split('/')

    activity_item = create(:activity_item,
                           :docker,
                           :with_deploying_event,
                           namespace: namespace,
                           name: name,
                           tag: container.tag,
                           container: container,
                           deployment: @deployment)

    namespace = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        metadata: {
          annotations: {
            network_connectivity: {
              containers: {
                container.id => {
                  service: {
                    status: :pending,
                  },
                },
              },
            }.to_json,
          },
        },
      },
    )

    stubbed_controller_get_deployment_request = stub_controller_get_deployment_request(@deployment, namespace)

    pod_name = generate(:name)
    deployed_at = Time.current
    current_time = (deployed_at - 25.minute).iso8601
    node_name = generate(:name)
    restart_count = 3

    pods = UffizziCore::Converters.deep_lower_camelize_keys(
      [
        {
          metadata: {
            name: pod_name,
            creation_timestamp: current_time,
          },
          spec: {
            node_name: node_name,
          },
          status: {
            container_statuses: [
              {
                name: UffizziCore::ContainerService.pod_name(container),
                restart_count: restart_count,
                image: container.image_name,
                state: {
                  running: {
                    started_at: current_time,
                  },
                },
              },
            ],
          },
        },
      ],
    )

    stubbed_controller_containers_request = stub_controller_containers_request(@deployment, pods)

    differences = {
      -> { UffizziCore::Event.count } => 0,
      -> { UffizziCore::Deployment::ManageDeployActivityItemJob.jobs.size } => 1,
    }

    assert_difference differences do
      UffizziCore::ActivityItemService.manage_deploy_activity_item(activity_item)

      assert_requested stubbed_controller_get_deployment_request
      assert_requested stubbed_controller_containers_request
    end
  end

  test '#manage_deploy_activity_item - resource is unavailable' do
    repo = create(:repo, :docker_hub, project: @project)
    container = create(:container, :with_public_port, deployment: @deployment, repo: repo, image: 'library/nginx')
    namespace, name = container.image.split('/')
    activity_item = create(:activity_item,
                           :with_building_event,
                           :docker,
                           namespace: namespace,
                           name: name,
                           tag: container.tag,
                           container: container,
                           deployment: @deployment)

    domain_name = generate(:kubernetes_name)

    namespace = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        metadata: {
          annotations: {
            network_connectivity: {
              containers: {
                container.id => {
                  service: {
                    ip: '127.0.0.1',
                    status: :failed,
                    port: container.port,
                    domain_name: domain_name,
                  },
                },
              },
            }.to_json,
          },
        },
      },
    )

    stubbed_controller_get_deployment_request = stub_controller_get_deployment_request(@deployment, namespace)

    pod_name = generate(:name)
    deployed_at = Time.current
    current_time = (deployed_at - 25.minute).iso8601
    node_name = generate(:name)
    restart_count = 3

    pods = UffizziCore::Converters.deep_lower_camelize_keys(
      [
        {
          metadata: {
            name: "#{Settings.controller.namespace_prefix}#{pod_name}",
            creation_timestamp: current_time,
          },
          spec: {
            node_name: node_name,
          },
          status: {
            container_statuses: [
              {
                name: UffizziCore::ContainerService.pod_name(container),
                restart_count: restart_count,
                image: container.image_name,
                state: {
                  terminated: {},
                },
              },
            ],
          },
        },
      ],
    )

    stubbed_controller_containers_request = stub_controller_containers_request(@deployment, pods)

    differences = {
      -> { UffizziCore::Event.count } => 1,
      -> { UffizziCore::Event.with_state(UffizziCore::Event.state.failed).count } => 1,
      -> { UffizziCore::Deployment::ManageDeployActivityItemJob.jobs.size } => 0,
    }

    assert_difference differences do
      UffizziCore::ActivityItemService.manage_deploy_activity_item(activity_item)

      assert_requested stubbed_controller_get_deployment_request
      assert_requested stubbed_controller_containers_request
    end
  end

  test '#manage_deploy_activity_item - successfully deployed resources' do
    repo = create(:repo, :docker_hub, project: @project)
    container = create(:container, :with_public_port, deployment: @deployment, repo: repo, image: 'library/nginx')
    namespace, name = container.image.split('/')
    activity_item = create(:activity_item,
                           :with_deploying_event,
                           :docker,
                           namespace: namespace,
                           name: name,
                           tag: container.tag,
                           container: container,
                           deployment: @deployment)

    domain_name = generate(:kubernetes_name)

    namespace = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        metadata: {
          annotations: {
            network_connectivity: {
              containers: {
                container.id => {
                  service: {
                    ip: '127.0.0.1',
                    status: :success,
                    port: container.port,
                    domain_name: domain_name,
                  },
                },
              },
            }.to_json,
          },
        },
      },
    )

    stubbed_controller_get_deployment_request = stub_controller_get_deployment_request(@deployment, namespace)

    pod_name = generate(:name)
    deployed_at = Time.current
    current_time = (deployed_at - 25.minute).iso8601
    node_name = generate(:name)
    restart_count = 0

    pods = UffizziCore::Converters.deep_lower_camelize_keys(
      [
        {
          metadata: {
            name: "#{Settings.controller.namespace_prefix}#{pod_name}",
            creation_timestamp: current_time,
          },
          spec: {
            node_name: node_name,
          },
          status: {
            container_statuses: [
              {
                name: UffizziCore::ContainerService.pod_name(container),
                restart_count: restart_count,
                image: container.image_name,
                state: {
                  running: {
                    started_at: current_time,
                  },
                },
              },
            ],
          },
        },
      ],
    )

    stubbed_controller_containers_request = stub_controller_containers_request(@deployment, pods)

    differences = {
      -> { UffizziCore::Event.count } => 1,
      -> { UffizziCore::Event.with_state(UffizziCore::Event.state.deployed).count } => 1,
      -> { UffizziCore::Deployment::ManageDeployActivityItemJob.jobs.size } => 0,
      -> { UffizziCore::Deployment::SendGithubPreviewMessageJob.jobs.size } => 0,
    }

    assert_difference differences do
      UffizziCore::ActivityItemService.manage_deploy_activity_item(activity_item)
      assert_requested stubbed_controller_get_deployment_request
      assert_requested stubbed_controller_containers_request
    end
  end

  test '#manage_deploy_activity_item - successfully deployed github container from continuous preview' do
    namespace = generate(:namespace)
    name = generate(:name)
    branch = generate(:branch)
    image = "#{namespace}/#{name}"

    create(:credential, :github, :active, account: @user.organizational_account, username: namespace)
    repo = create(:repo, :github, namespace: namespace, name: name, branch: branch, project: @project)
    create(:build, :successful, :deployed, repo: repo)
    continuous_preview_payload = { pull_request: { id: 1, message: '', repository_full_name: image } }
    deployment = create(:deployment, project: @project, continuous_preview_payload: continuous_preview_payload)
    container = create(:container, :with_public_port, receive_incoming_requests: true, deployment: deployment, repo: repo, image: image,
                                                      tag: branch)
    activity_item = create(:activity_item, :github, :with_deploying_event, namespace: namespace, name: name, branch: branch,
                                                                           container: container, deployment: deployment)

    domain_name = generate(:kubernetes_name)

    namespace = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        metadata: {
          annotations: {
            network_connectivity: {
              containers: {
                container.id => {
                  service: {
                    ip: '127.0.0.1',
                    status: :success,
                    port: container.port,
                    domain_name: domain_name,
                  },
                },
              },
            }.to_json,
          },
        },
      },
    )

    stubbed_controller_get_deployment_request = stub_controller_get_deployment_request(deployment, namespace)

    pod_name = generate(:name)
    deployed_at = Time.current
    current_time = (deployed_at - 25.minute).iso8601
    restart_count = 0

    pods = UffizziCore::Converters.deep_lower_camelize_keys(
      [
        {
          metadata: {
            name: "#{Settings.controller.namespace_prefix}#{pod_name}",
            creation_timestamp: current_time,
          },
          spec: {
            node_name: generate(:name),
          },
          status: {
            container_statuses: [
              {
                name: UffizziCore::ContainerService.pod_name(container),
                restart_count: restart_count,
                image: container.image_name,
                state: {
                  running: {
                    started_at: current_time,
                  },
                },
              },
            ],
          },
        },
      ],
    )

    stubbed_controller_containers_request = stub_controller_containers_request(deployment, pods)

    differences = {
      -> { UffizziCore::Event.count } => 1,
      -> { UffizziCore::Event.with_state(UffizziCore::Event.state.deployed).count } => 1,
      -> { UffizziCore::Deployment::ManageDeployActivityItemJob.jobs.size } => 0,
      -> { UffizziCore::Deployment::SendGithubPreviewMessageJob.jobs.size } => 1,
    }

    assert_difference differences do
      UffizziCore::ActivityItemService.manage_deploy_activity_item(activity_item)

      assert_requested stubbed_controller_containers_request
      assert_requested stubbed_controller_get_deployment_request
    end
  end
end
