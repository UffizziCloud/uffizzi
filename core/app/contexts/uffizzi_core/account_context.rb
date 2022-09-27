# frozen_string_literal: true

class UffizziCore::AccountContext
  attr_reader :user, :user_access_module, :account, :params

  def initialize(user, user_access_module, account, params)
    @user = user
    @user_access_module = user_access_module
    @account = account
    @params = params
  end
end
