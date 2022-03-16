# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::Deployments::ContainersControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_organizational_account)
    sign_in @user

    @account = @user.organizational_account
    @project = create(:project, :with_members, account: @user.organizational_account, members: [@user])
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
    )

    params = { project_slug: @project.slug, deployment_id: @deployment.id }

    get :index, params: params, format: :json

    assert_response :success
  end
end
