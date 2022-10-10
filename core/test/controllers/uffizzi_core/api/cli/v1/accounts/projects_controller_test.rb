# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::Accounts::ProjectsControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_personal_account)
    sign_in @user
  end

  test '#create' do
    attributes = attributes_for(:project)

    differences = {
      -> { UffizziCore::Project.count } => 1,
      -> { UffizziCore::UserProject.count } => 1,
    }

    assert_difference differences do
      post :create, params: { account_id: @user.personal_account.id, project: attributes }, format: :json
    end

    assert_response :success
  end
end
