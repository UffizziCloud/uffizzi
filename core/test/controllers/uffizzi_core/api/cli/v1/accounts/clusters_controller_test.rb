# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Accounts::ClustersControllerTest < ActionController::TestCase
  setup do
    @developer = create(:user, :with_organizational_account)
    sign_in(@developer)
  end

  test '#index' do
    admin_user = create(:user, :with_organizational_account)
    admin_user_org_account = admin_user.accounts.organizational.first
    create(:membership, :developer, user: @developer, account: admin_user_org_account)
    admin_project = create(:project, :with_members, account: admin_user_org_account, members: [admin_user, @developer])
    create(:cluster, :deployed, project: admin_project, deployed_by_id: admin_user.id)
    showable_cluster1 = create(:cluster, :deployed, project: admin_project, deployed_by_id: @developer.id)

    admin_project2 = create(:project, :with_members, account: admin_user_org_account, members: [admin_user])
    create(:user_project, :admin, user: @developer, project: admin_project2)
    showable_cluster2 = create(:cluster, :deployed, project: admin_project2, deployed_by_id: admin_user.id)

    other_user = create(:user, :with_organizational_account)
    other_user_account = other_user.accounts.organizational.first
    create(:membership, :developer, user: @developer, account: other_user_account)
    other_project = create(:project, :with_members, account: other_user_account, members: [other_user, @developer])
    create(:cluster, :deployed, project: other_project, deployed_by_id: other_user.id)
    create(:cluster, :deployed, project: other_project, deployed_by_id: @developer.id)

    get :index, params: { account_id: admin_user_org_account.id }, format: :json

    assert_response(:success)

    clusters_data = JSON.parse(response.body)['clusters']
    assert_equal(2, clusters_data.count)
    assert_equal([showable_cluster1.name, showable_cluster2.name], clusters_data.pluck('name').sort)

    actual_project_name1 = clusters_data.min_by { |c| c['name'] }.dig('project', 'name')
    actual_project_name2 = clusters_data.max_by { |c| c['name'] }.dig('project', 'name')
    assert_equal(showable_cluster1.project.name, actual_project_name1)
    assert_equal(showable_cluster2.project.name, actual_project_name2)
  end
end
