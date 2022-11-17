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
    controller_response = json_fixture('files/controller/logs.json')

    pod_name = UffizziCore::ContainerService.pod_name(@container)
    stubbed_request = stub_container_log_request(@deployment.id, pod_name, @limit, @previous, controller_response)

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

    data = JSON.parse(response.body)

    entry = data['logs'].first
    assert(entry['timestamp'].present?)
    assert(entry['timestamp'].exclude?('Z'))
    assert(entry['payload'].present?)
  end

  test '#index with empty logs info' do
    controller_response = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        logs: [],
      },
    )

    stubbed_request = stub_container_log_request(@deployment.id, @pod_name, @limit, @previous, controller_response)

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
    controller_response = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        logs: [],
      },
    )
    stubbed_request = stub_container_log_request(@deployment.id, @pod_name, @limit, @previous, controller_response)

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
