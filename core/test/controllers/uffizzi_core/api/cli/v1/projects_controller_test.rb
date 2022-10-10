# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::ProjectsControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_personal_account)
    sign_in @user

    @project = create(:project, :with_members, account: @user.personal_account, members: [@user])
  end

  test '#index' do
    get :index, format: :json

    assert_response :success
  end

  test '#show' do
    create(:compose_file, project: @project, added_by: @user)
    create(:secret, resource: @project)
    create(:deployment, project: @project)

    get :show, params: { slug: @project.slug }, format: :json

    assert_response :success

    assert_equal(@project.name, JSON.parse(response.body)['project']['name'])
  end

  test '#destroy' do
    differences = {
      -> { UffizziCore::Project.active.count } => -1,
    }

    assert_difference differences do
      delete :destroy, params: { slug: @project.slug }, format: :json
    end

    assert_response :success
  end
end
