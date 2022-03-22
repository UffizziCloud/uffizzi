# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::Deployments::ActivityItemsControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_organizational_account)
    @project = create(:project, :with_members, account: @user.organizational_account, members: [@user])
    @deployment = create(:deployment, project: @project)

    sign_in @user
  end

  test '#index' do
    container = create(:container, :with_public_port, deployment: @deployment)
    create(:activity_item, :with_building_event, tag: container.tag, container: container, deployment: @deployment)

    params = {
      project_slug: @project.slug,
      deployment_id: @deployment.id,
    }

    get :index, params: params, format: :json

    assert_response :success
  end
end
