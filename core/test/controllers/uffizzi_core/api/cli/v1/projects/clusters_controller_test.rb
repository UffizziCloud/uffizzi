# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Projects::ClustersControllerTest < ActionController::TestCase
  setup do
    @admin = create(:user, :with_organizational_account)
    @account = @admin.accounts.organizational.first
    @project = create(:project, :with_members, members: [@admin], account: @account)

    @developer = create(:user)
    create(:membership, :developer, account: @account, user: @developer)
    create(:user_project, :developer, project: @project, user: @developer)
    create(:kubernetes_distribution, :default)
  end

  teardown do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.inline!
  end

  test '#index lists all clusters to admins' do
    sign_in(@admin)

    create(:cluster, project: @project, deployed_by: @developer)

    params = {
      project_slug: @project.slug,
    }
    get :index, params: params, format: :json

    assert_response(:success)
    data = JSON.parse(response.body)
    assert_equal(1, data['clusters'].count)
  end

  test '#index only shows clusters deployed by the same user for non-adminss' do
    create(:cluster, project: @project, deployed_by: @admin)
    create(:cluster, project: @project, deployed_by: @developer)
    sign_in(@developer)

    params = {
      project_slug: @project.slug,
    }
    get :index, params: params, format: :json

    assert_response(:success)
    data = JSON.parse(response.body)
    assert_equal(1, data['clusters'].count)
  end

  test '#create' do
    sign_in(@admin)
    cluster_creation_data = json_fixture('files/controller/cluster_not_ready.json')
    params = {
      project_slug: @project.slug,
      cluster: {
        name: cluster_creation_data[:name],
      },
    }

    expected_request = {
      name: cluster_creation_data[:name],
      manifest: nil,
      base_ingress_host: /#{UffizziCore::Cluster::NAMESPACE_PREFIX}\d/,
    }
    stubbed_create_cluster_request = stub_create_cluster_request_with_expected(cluster_creation_data, expected_request)
    stubbed_create_namespace_request = stub_create_namespace_request
    cluster_show_data = json_fixture('files/controller/cluster_ready.json')
    stubbed_cluster_request = stub_get_cluster_request(cluster_show_data)

    differences = {
      -> { UffizziCore::Cluster.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response(:success)
    assert(UffizziCore::Cluster.find_by(name: cluster_creation_data[:name]).creation_source.manual?)
    assert_requested(stubbed_create_cluster_request)
    assert_requested(stubbed_create_namespace_request)
    assert_requested(stubbed_cluster_request)
  end

  test '#create with wrong k8s version' do
    sign_in(@admin)

    params = {
      project_slug: @project.slug,
      cluster: {
        name: 'my cluster',
        k8s_version: 'wrong.version',
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

  test '#create when enabled cluster with the same name exists' do
    sign_in(@admin)
    name = 'test'
    create(:cluster, project: @project, deployed_by: @admin, name: name)

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
    sign_in(@admin)
    manifest = File.read('test/fixtures/files/cluster/manifest.yml')
    cluster_creation_data = json_fixture('files/controller/cluster_not_ready.json')
    cluster_show_data = json_fixture('files/controller/cluster_ready.json')

    params = {
      project_slug: @project.slug,
      cluster: {
        name: cluster_creation_data[:name],
        manifest: manifest,
      },
    }

    stubbed_create_namespace_request = stub_create_namespace_request
    expected_request = {
      name: cluster_creation_data[:name],
      manifest: manifest,
      base_ingress_host: /#{UffizziCore::Cluster::NAMESPACE_PREFIX}\d/,
    }
    stubbed_create_cluster_request = stub_create_cluster_request_with_expected(cluster_creation_data, expected_request)
    stubbed_get_cluster_request = stub_get_cluster_request(cluster_show_data)

    differences = {
      -> { UffizziCore::Cluster.count } => 1,
    }

    assert_difference differences do
      post :create, params: params, format: :json
    end

    assert_response(:success)
    assert_requested(stubbed_create_cluster_request)
    assert_requested(stubbed_create_namespace_request)
    assert_requested(stubbed_get_cluster_request)
  end

  test '#show shows cluster created by the same developer' do
    cluster = create(:cluster, project: @project, deployed_by: @developer, name: 'test')
    sign_in(@developer)

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    get :show, params: params, format: :json

    assert_response(:success)
  end

  test '#show does not show cluster created by a different user to developer' do
    sign_in(@developer)

    cluster = create(:cluster, project: @project, deployed_by: @admin, name: 'test')

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    get :show, params: params, format: :json

    assert_response(:not_found)
  end

  test '#show shows clusters created by a different user to admin' do
    sign_in(@admin)

    cluster = create(:cluster, project: @project, deployed_by: @developer, name: 'test')

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    get :show, params: params, format: :json

    assert_response(:success)
  end

  test '#scale_down' do
    sign_in(@admin)

    cluster = create(:cluster, project: @project, deployed_by: @admin, name: 'test', state: UffizziCore::Cluster::STATE_DEPLOYED)
    stubbed_scale_request = stub_scale_cluster_request

    cluster_show_data = json_fixture('files/controller/cluster_asleep.json')
    stubbed_cluster_request = stub_get_cluster_request(cluster_show_data)

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    put :scale_down, params: params, format: :json

    assert_response(:success)
    assert(cluster.reload.scaled_down?)
    assert_requested(stubbed_scale_request)
    assert_requested(stubbed_cluster_request)
  end

  test '#scale_up' do
    sign_in(@admin)

    cluster = create(:cluster, project: @project, deployed_by: @admin, name: 'test', state: UffizziCore::Cluster::STATE_SCALED_DOWN)
    stubbed_scale_request = stub_scale_cluster_request
    cluster_show_data = json_fixture('files/controller/cluster_awake.json')
    stubbed_cluster_request = stub_get_cluster_request(cluster_show_data)

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    put :scale_up, params: params, format: :json

    assert_response(:success)
    assert(cluster.reload.deployed?)
    assert_requested(stubbed_scale_request)
    assert_requested(stubbed_cluster_request)
  end

  test '#sync when the data is actual' do
    sign_in(@admin)
    cluster = create(:cluster, project: @project, deployed_by: @admin, name: 'test', state: UffizziCore::Cluster::STATE_DEPLOYED)

    cluster_show_data = json_fixture('files/controller/cluster_awake.json')
    stubbed_cluster_request = stub_get_cluster_request(cluster_show_data)

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    put :sync, params: params, format: :json

    assert_requested(stubbed_cluster_request)
    assert(cluster.reload.deployed?)
  end

  test '#sync when the data needs to be updated' do
    sign_in(@admin)
    cluster = create(:cluster, project: @project, deployed_by: @admin, name: 'test', state: UffizziCore::Cluster::STATE_DEPLOYED)

    cluster_show_data = json_fixture('files/controller/cluster_asleep.json')
    stubbed_cluster_request = stub_get_cluster_request(cluster_show_data)

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    put :sync, params: params, format: :json

    assert_requested(stubbed_cluster_request)
    assert(cluster.reload.scaled_down?)
  end

  test '#destroy developer can destroy a cluster created by him' do
    sign_in(@developer)

    cluster = create(:cluster, :deployed, project: @project, deployed_by: @developer, name: 'test')
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

  test '#destroy developer cannot destroy a cluster created by other user' do
    sign_in(@developer)

    cluster = create(:cluster, :deployed, project: @project, deployed_by: @admin, name: 'test')
    stubbed_delete_namespace_request = stub_delete_namespace_request(cluster)

    params = {
      project_slug: @project.slug,
      name: cluster.name,
    }

    delete :destroy, params: params, format: :json

    assert_response(:not_found)
    refute_requested(stubbed_delete_namespace_request)
  end

  test '#destroy admin can destroy a cluster created by other user' do
    sign_in(@admin)

    cluster = create(:cluster, :deployed, project: @project, deployed_by: @developer, name: 'test')
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
