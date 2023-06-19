# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::ClustersControllerTest < ActionController::TestCase
  setup do
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

    data = json_fixture('files/controller/cluster_not_ready.json')
    stubbed_create_cluster_request = stub_create_cluster_request(data)
    stubbed_create_namespace_request = stub_create_namespace_request

    differences = {
      -> { UffizziCore::Cluster.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response(:success)
    assert_requested(stubbed_create_cluster_request)
    assert_requested(stubbed_create_namespace_request)
  end

  test '#create when enabled cluster with the same name exists' do
    name = 'test'
    create(:cluster, project: @project, deployed_by: @user, name: name)

    params = {
      project_slug: @project.slug,
      cluster: {
        name: name,
      },
    }

    differences = {
      -> { UffizziCore::Cluster.count } => 0,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response(:unprocessable_entity)
  end

  test '#create with manifest' do
    manifest = File.read('test/fixtures/files/cluster/manifest.yml')

    params = {
      project_slug: @project.slug,
      cluster: {
        name: 'test',
        manifest: manifest,
      },
    }

    data = json_fixture('files/controller/cluster_not_ready.json')
    stubbed_create_cluster_request = stub_create_cluster_request(data)
    stubbed_create_namespace_request = stub_create_namespace_request

    differences = {
      -> { UffizziCore::Cluster.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response(:success)
    assert_requested(stubbed_create_cluster_request)
    assert_requested(stubbed_create_namespace_request)
  end

  test '#show' do
    cluster = create(:cluster, project: @project, deployed_by: @user, name: 'test')
    data = json_fixture('files/controller/cluster_ready.json')
    stubbed_cluster_request = stub_get_cluster_request(data)

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    get :show, params: params, format: :json

    assert_response(:success)
    assert_requested(stubbed_cluster_request)
  end

  test '#destroy' do
    cluster = create(:cluster, :deployed, project: @project, deployed_by: @user, name: 'test')
    stubbed_delete_namespace_request = stub_delete_namespace_request(cluster)

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    delete :destroy, params: params, format: :json

    assert_response(:success)
    assert(cluster.reload.disabled?)
    assert_requested(stubbed_delete_namespace_request)
  end
end
