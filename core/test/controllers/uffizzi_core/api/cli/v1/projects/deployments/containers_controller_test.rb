# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::Deployments::ContainersControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_personal_account)
    sign_in @user

    @account = @user.personal_account
    @project = create(:project, :with_members, account: @user.personal_account, members: [@user])
    @deployment = create(:deployment, project: @project)
  end

  test '#index' do
    repo = create(:repo, :docker_hub, project: @project)

    create(
      :container,
      deployment: @deployment,
      repo: repo,
      image: 'uffizzitest/webhooks-test-app',
      tag: 'latest',
      secret_variables: [{ 'name' => 'test', 'value' => 'test' }],
    )

    params = { project_slug: @project.slug, deployment_id: @deployment.id }

    get :index, params: params, format: :json

    assert_response :success
  end

  test '#k8s_container_description - with last state' do
    container = create(:container, deployment: @deployment, controller_name: 'f03d008a48')
    controller_response = json_fixture('files/controller/deployment_containers_with_error.json')
    stubbed_request = stub_controller_containers_request(@deployment, controller_response)
    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
      container_name: container.service_name,
    }

    get :k8s_container_description, params: params, format: :json

    assert_requested stubbed_request
    assert_response :success

    data = JSON.parse(response.body)
    expected_result = {
      'last_state' => {
        'code' => 'terminated',
        'reason' => 'Error',
        'exit_code' => 127,
        'started_at' => '2022-12-05T18:11:46Z',
        'finished_at' => '2022-12-05T18:11:46Z',
      },
    }

    assert_equal(expected_result, data)
  end

  test '#k8s_container_description - with empty last state' do
    container = create(:container, deployment: @deployment, controller_name: 'f03d008a48')
    controller_response = json_fixture('files/controller/deployment_containers.json')
    stubbed_request = stub_controller_containers_request(@deployment, controller_response)
    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
      container_name: container.service_name,
    }

    get :k8s_container_description, params: params, format: :json

    assert_requested stubbed_request
    assert_response :success

    data = JSON.parse(response.body)
    expected_result = { 'last_state' => {} }

    assert_equal(expected_result, data)
  end
end
