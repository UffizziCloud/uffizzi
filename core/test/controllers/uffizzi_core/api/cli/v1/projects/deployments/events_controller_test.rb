# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::Deployments::EventsControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_organizational_account)
    @project = create(:project, :with_members, account: @user.organizational_account, members: [@user])
    @deployment = create(:deployment, project: @project)

    sign_in @user
  end

  test '#index' do
    first_timestamp = generate(:string)
    last_timestamp = generate(:string)
    reason = generate(:string)
    message = generate(:string)

    events = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        items: [
          {
            involved_object: { kind: 'Pod' },
            first_timestamp: first_timestamp,
            last_timestamp: last_timestamp,
            reason: reason,
            message: message,
          },
        ],
      },
    )

    stubbed_controller_get_deployment_events = stub_controller_get_deployment_events(@deployment, events)

    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
    }

    get :index, params: params, format: :json

    assert_requested(stubbed_controller_get_deployment_events)

    assert_response :success

    collected_result = {
      events: [
        {
          first_timestamp: first_timestamp,
          last_timestamp: last_timestamp,
          reason: reason,
          message: message,
        },
      ],
    }.to_json

    assert_equal(collected_result, response.body)
  end

  test '#index with empty logs info' do
    events = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        items: [],
      },
    )

    stubbed_controller_get_deployment_events = stub_controller_get_deployment_events(@deployment, events)

    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
    }

    get :index, params: params, format: :json

    assert_requested(stubbed_controller_get_deployment_events)

    assert_response :success
  end
end
