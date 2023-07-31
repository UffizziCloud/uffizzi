# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Accounts::ProjectsControllerTest < ActionController::TestCase
  setup do
    @admin = create(:user, :with_organizational_account)
    @account = @admin.accounts.organizational.first
    sign_in(@admin)
  end

  test '#index' do
    create(:project, :with_members, account: @account, members: [@admin])

    get :index, params: { account_id: @account.id }, format: :json

    data = JSON.parse(response.body)
    assert(data['projects'].first['account'].present?)
    assert_response(:success)
  end

  test '#create' do
    attributes = attributes_for(:project)
    create(:user, :developer_in_organization, organization: @account)

    differences = {
      -> { UffizziCore::Project.count } => 1,
      -> { UffizziCore::UserProject.count } => 2,
    }

    assert_difference differences do
      post :create, params: { account_id: @account.id, project: attributes }, format: :json
    end

    assert_response(:success)
  end
end
