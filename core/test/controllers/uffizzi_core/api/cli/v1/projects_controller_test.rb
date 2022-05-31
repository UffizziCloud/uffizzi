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
end
