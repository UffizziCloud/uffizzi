# frozen_string_literal: true

class UffizziCore::UserAccessService
  attr_accessor :user_access_module

  delegate :admin_access_to_account?, :developer_access_to_account?, :viewer_access_to_account?,
           :admin_or_developer_access_to_account?, :any_access_to_account?, :admin_access_to_project?,
           :developer_access_to_project?, :viewer_access_to_project?, :admin_or_developer_access_to_project?,
           :any_access_to_project?, :global_admin?, to: :@user_access_module

  def initialize(user_access_module)
    @user_access_module = user_access_module
  end
end
