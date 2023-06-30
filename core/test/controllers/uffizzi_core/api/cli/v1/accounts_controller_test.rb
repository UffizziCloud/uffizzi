# frozen_string_literal: true

require 'test_helper'

class UffizziCore::Api::Cli::V1::AccountsControllerTest < ActionController::TestCase
  setup do
    @user = create(:user, :with_personal_account)
    sign_in(@user)
  end

  test '#index' do
    get :index, format: :json

    assert_response(:success)
  end

  test '#show' do
    get :show, params: { name: 'wrong' }, format: :json

    assert_response(:not_found)
  end
end
