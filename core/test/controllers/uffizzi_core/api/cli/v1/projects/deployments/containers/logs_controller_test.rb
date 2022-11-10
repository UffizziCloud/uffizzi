# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::Deployments::Containers::LogsControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_personal_account)
    @project = create(:project, :with_members, account: @user.personal_account, members: [@user])
    @deployment = create(:deployment, project: @project)
    @container = create(:container, deployment: @deployment)
    @pod_name = UffizziCore::ContainerService.pod_name(@container)
    @limit = 30
    @previous = false

    sign_in @user
  end

  test '#index' do
    timestamp = generate(:string)
    payload = generate(:string)

    logs = { logs: ["#{timestamp} #{payload}"] }

    pod_name = UffizziCore::ContainerService.pod_name(@container)
    stubbed_request = stub_container_log_request(@deployment.id, pod_name, limit, logs)

    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
      container_name: @container.service_name,
      limit: @limit,
      previous: @previous,
    }

    get :index, params: params, format: :json

    assert_requested stubbed_request

    assert_response :success

    collected_result = {
      logs: [
        {
          timestamp: timestamp,
          payload: payload,
        },
      ],
    }.to_json

    assert_equal collected_result, response.body
  end

  test '#index with empty logs info' do
    logs = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        logs: [],
      },
    )

    stubbed_request = stub_container_log_request(@deployment.id, @pod_name, @limit, @previous, logs)

    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
      container_name: @container.service_name,
      limit: @limit,
      previous: @previous,
    }

    get :index, params: params, format: :json

    assert_requested stubbed_request

    assert_response :success
  end

  test '#index with controller error' do
    logs = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        logs: [],
      },
    )
    stubbed_request = stub_container_log_request(@deployment.id, @pod_name, @limit, @previous, logs)

    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
      container_name: @container.service_name,
      limit: @limit,
      previous: @previous,
    }

    get :index, params: params, format: :json

    assert_requested stubbed_request

    assert_response :success
  end
end
