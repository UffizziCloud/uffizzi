# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::Clusters::IngressesControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_personal_account)
    @project = create(:project, :with_members, account: @user.personal_account, members: [@user])
    @cluster = create(:cluster, project: @project, deployed_by: @user)

    sign_in @user
  end

  test '#index' do
    data = json_fixture('files/controller/ingresses.json')
    stubbed_get_ingresses_request = stub_get_ingresses(data)

    params = { project_slug: @project.slug, cluster_name: @cluster.name }

    get :index, params: params, format: :json

    assert_response(:success)
    assert_requested(stubbed_get_ingresses_request)
  end
end
