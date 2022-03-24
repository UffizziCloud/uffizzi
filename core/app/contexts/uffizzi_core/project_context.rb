# frozen_string_literal: true

class UffizziCore::ProjectContext
  attr_reader :user, :user_access_module, :project, :account, :params

  def initialize(user, user_access_module, project, params)
    @user = user
    @user_access_module = user_access_module
    @account = user.organizational_account
    @project = project
    @params = params
  end
end
