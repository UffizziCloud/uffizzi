# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Accounts::User::Projects::ClustersControllerTest < ActionController::TestCase
  setup do
    @developer = create(:user, :with_organizational_account)
    @account = @developer.accounts.organizational.first
    sign_in(@developer)
  end

  test '#index' do
    project = create(:project, :with_members, account: @account, members: [@developer])
    dev_cluster = create(:cluster, :deployed, :dev, project: project, deployed_by_id: @developer.id)
    create(:cluster, :deployed, project: project, deployed_by_id: @developer.id)

    q_params = { kind_eq: UffizziCore::Cluster.kind.dev }

    get :index, params: { account_id: @account.id, project_slug: project.slug, q: q_params }, format: :json

    assert_response(:success)

    clusters_data = JSON.parse(response.body)['clusters']

    assert_equal(1, clusters_data.count)
    assert_equal(dev_cluster.name, clusters_data[0]['name'])
  end
end
