# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::Deployments::Containers::LogsControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_organizational_account)
    @project = create(:project, :with_members, account: @user.organizational_account, members: [@user])
    @deployment = create(:deployment, project: @project)
    @container = create(:container, deployment: @deployment)

    sign_in @user
  end

  test '#index' do
    insert_id = generate(:string)
    payload = generate(:string)
    limit = 30

    logs = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        logs: [
          {
            insert_id: insert_id,
            payload: payload,
          },
        ],
      },
    )
    pod_name = UffizziCore::ContainerService.pod_name(@container)
    stubbed_request = stub_container_log_request(deployment_id, pod_name, limit, logs)

    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
      container_id: @container.id,
      limit: 30,
    }

    get :index, params: params, format: :json

    assert_requested stubbed_request

    assert_response :success

    collected_result = {
      logs: [
        {
          insert_id: insert_id,
          payload: payload,
        },
      ],
    }.to_json

    assert_equal collected_result, response.body
  end

  test '#index with empty logs info' do
    limit = 30

    logs = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        logs: [],
      },
    )

    pod_name = UffizziCore::ContainerService.pod_name(@container)
    stubbed_request = stub_container_log_request(deployment_id, pod_name, limit, logs)

    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
      container_id: @container.id,
      limit: 30,
    }

    get :index, params: params, format: :json

    assert_requested stubbed_request

    assert_response :success
  end

  test '#index with controller error' do
    limit = 30

    logs = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        logs: [],
      },
    )
    pod_name = UffizziCore::ContainerService.pod_name(@container)
    stubbed_request = stub_container_log_request(deployment_id, pod_name, limit, logs)


    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
      container_id: @container.id,
      limit: 30,
    }

    get :index, params: params, format: :json

    assert_requested stubbed_request

    assert_response :success
  end
end
