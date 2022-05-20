# frozen_string_literal: true

require 'test_helper'

class UffizziCore::DeploymentServiceTest < ActiveSupport::TestCase
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

  test '#deploy_containers - empty spec' do
    stubbed_deploy_containers_request = stub_request(:post, "#{Settings.controller.url}/deployments/#{@deployment.id}/containers")

    UffizziCore::DeploymentService.deploy_containers(@deployment)

    assert_requested stubbed_deploy_containers_request
    assert { UffizziCore::Deployment::DeployContainersJob.jobs.empty? }
    assert { UffizziCore::Deployment::ManageDeployActivityItemJob.jobs.empty? }
  end

  test '#deploy_containers - start to deploy dockerhub container' do
    repo = create(:repo, :docker_hub, project: @project)
    create(:container, :active, deployment: @deployment, repo: repo)

    stubbed_deploy_containers_request = stub_request(:post, "#{Settings.controller.url}/deployments/#{@deployment.id}/containers")

    differences = {
      -> { UffizziCore::Event.count } => 1,
      -> { UffizziCore::Event.with_state(UffizziCore::Event.state.deploying).count } => 1,
      -> { UffizziCore::Deployment::DeployContainersJob.jobs.size } => 0,
      -> { UffizziCore::Deployment::ManageDeployActivityItemJob.jobs.size } => 1,
    }

    assert_difference differences do
      UffizziCore::DeploymentService.deploy_containers(@deployment)
    end
    assert_requested stubbed_deploy_containers_request
  end

  test '#disable when deployment has no compose file' do
    container = create(:container, :with_public_port, deployment: @deployment)

    differences = {
      -> { UffizziCore::Deployment.active.count } => -1,
      -> { UffizziCore::ComposeFile.count } => 0,
      -> { UffizziCore::Template.count } => 0,
    }

    assert_difference differences do
      UffizziCore::DeploymentService.disable!(@deployment)
    end

    container.reload
    assert { container.disabled? }
  end

  test '#disable when the main compose file exists' do
    user = create(:user, :with_organizational_account)
    compose_file = create(:compose_file, project: @project, added_by: user)
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
    template = create(:template, :compose_file_source, compose_file: compose_file, project: @project, payload: template_payload,
                                                       added_by: user)
    deployment = create(:deployment, project: @project, compose_file: compose_file, template: template)
    container = create(:container, :with_public_port, deployment: deployment)

    differences = {
      -> { UffizziCore::Deployment.active.count } => -1,
      -> { UffizziCore::ComposeFile.count } => 0,
      -> { UffizziCore::Template.count } => 0,
    }

    assert_difference differences do
      UffizziCore::DeploymentService.disable!(deployment)
    end

    container.reload
    assert { container.disabled? }
  end

  test '#disable when a temporary compose file exists' do
    user = create(:user, :with_organizational_account)
    compose_file = create(:compose_file, :temporary, project: @project, added_by: user)
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
    template = create(:template, :compose_file_source, compose_file: compose_file, project: @project, payload: template_payload,
                                                       added_by: user)
    deployment = create(:deployment, project: @project, compose_file: compose_file, template: template)
    container = create(:container, :with_public_port, deployment: deployment)

    differences = {
      -> { UffizziCore::Deployment.active.count } => -1,
      -> { UffizziCore::ComposeFile.count } => -1,
      -> { UffizziCore::Template.count } => -1,
    }

    assert_difference differences do
      UffizziCore::DeploymentService.disable!(deployment)
    end

    container.reload
    assert { container.disabled? }
  end

  test '#failed? - container failed' do
    container = create(:container, deployment: @deployment)
    create(:activity_item, :with_failed_event, container: container, deployment: @deployment)

    deployment_failed = UffizziCore::DeploymentService.failed?(@deployment)

    assert(deployment_failed)
  end

  test '#failed? - container deployed' do
    container = create(:container, deployment: @deployment)
    create(:activity_item, :with_deployed_event, container: container, deployment: @deployment)

    deployment_failed = UffizziCore::DeploymentService.failed?(@deployment)

    refute(deployment_failed)
  end

  test '#failed? - no containers' do
    deployment_failed = UffizziCore::DeploymentService.failed?(@deployment)

    refute(deployment_failed)
  end
end
