# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::ClustersControllerTest < ActionController::TestCase
  setup do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
    @user = create(:user, :with_organizational_account)
    account = @user.accounts.organizational.first
    @project = create(:project, :with_members, members: [@user], account: account)

    sign_in(@user)
  end

  teardown do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#index' do
    create(:cluster, project: @project, deployed_by: @user)

    params = {
      project_slug: @project.slug,
    }
    get :index, params: params, format: :json

    assert_response(:success)
  end

  test '#create' do
    params = {
      project_slug: @project.slug,
      cluster: {
        name: 'test',
      },
    }

    stubbed_create_namespace_request = stub_create_namespace_request
    # TODO add response fixture
    data = ''
    stubbed_create_cluster_request = stub_create_cluster_request(data)

    differences = {
      -> { UffizziCore::Cluster.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response(:success)
    assert_requested(stubbed_create_namespace_request)
    assert_requested(stubbed_create_cluster_request)
  end

  test '#show' do
    cluster = create(:cluster, project: @project, deployed_by: @user)

    params = {
      project_slug: @project.slug,
      id: cluster.id,
    }

    get :show, params: params, format: :json

    assert_response(:success)
  end

  test '#destroy' do
    cluster = create(:cluster, :deployed, project: @project, deployed_by: @user)
    stubbed_delete_cluster_request = stub_delete_cluster_request

    params = {
      project_slug: @project.slug,
      id: cluster.id,
    }

    delete :destroy, params: params, format: :json

    assert_response(:success)
    assert(cluster.reload.disabled?)
    assert_requested(stubbed_delete_cluster_request)
  end
end
