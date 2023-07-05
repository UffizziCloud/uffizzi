# frozen_string_literal: true

require 'test_helper'

class UffizziCore::ManageActivityItemsServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user, :with_personal_account)
    @project = create(:project, account: @user.personal_account)
  end

  test '#container_status_items - deployment has no containers' do
    deployment = create(:deployment, project: @project)
    stubbed_response_containers = []

    namespace = UffizziCore::Converters.deep_lower_camelize_keys(
      {
        metadata: {
          annotations: {
            network_connectivity: {}.to_json,
          },
        },
      },
    )

    stub_controller_containers = stub_controller_containers_request(deployment, stubbed_response_containers)
    stub_get_controller_deployment = stub_controller_get_namespace_request(deployment, namespace)

    service = UffizziCore::ManageActivityItemsService.new(deployment)
    container_status_items = service.container_status_items

    assert { container_status_items.empty? }
    assert_requested(stub_get_controller_deployment)
    assert_requested(stub_controller_containers)
  end
end
