# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::ProjectsControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_organizational_account)
    sign_in @user

    @project = create(:project, :with_members, account: @user.organizational_account, members: [@user])
  end

  test '#index' do
    get :index, format: :json

    assert_response :success
  end

  test '#show' do
    create(:compose_file, project: @project, added_by: @user)
    create(:deployment, project: @project)

    get :show, params: { slug: @project.slug }, format: :json

    assert_response :success

    assert_equal(@project.name, JSON.parse(response.body)['project']['name'])
  end

  test '#create' do
    attributes = attributes_for(:project)

    differences = {
      -> { UffizziCore::Project.count } => 1,
      -> { UffizziCore::UserProject.count } => 1,
      -> { UffizziCore::Template.count } => 1,
      -> { UffizziCore::ConfigFile.count } => 1,
    }

    assert_difference differences do
      post :create, params: { project: attributes }, format: :json
    end

    assert_response :success
  end

  test '#destroy' do
    deployment_ids = @project.deployment_ids

    stubbed_requests = deployment_ids.map do |deployment_id|
      stub_request(:post, "#{Settings.controller.url}/clean")
        .with(body: { deployment_id: deployment_id })
        .to_return(status: 200, body: '', headers: {})
    end

    differences = {
      -> { UffizziCore::Project.active.count } => -1,
    }

    assert_difference differences do
      delete :destroy, params: { slug: @project.slug }, format: :json
    end

    stubbed_requests.each(&method(:assert_requested))

    assert_response :success
  end
end
