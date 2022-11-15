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

  test '#destroy' do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
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
    Sidekiq::Worker.clear_all
  end
end
