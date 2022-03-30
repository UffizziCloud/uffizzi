# frozen_string_literal: true

class UffizziCore::BaseContext
  attr_reader :user, :user_access_module, :params, :account

  def initialize(user, user_access_module, params)
    @user = user
    @user_access_module = user_access_module
    @account = user.organizational_account
    @params = params
  end
end
