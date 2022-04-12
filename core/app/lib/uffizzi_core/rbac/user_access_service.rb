# frozen_string_literal: true

module UffizziCore::Rbac::UserAccessService
  class << self
    def admin_access_to_account?(_user, _account)
      true
    end

    def any_access_to_account?(_user, _account)
      true
    end

    def admin_or_developer_access_to_project?(_user, _project)
      true
    end

    def any_access_to_project?(_user, _project)
      true
    end
  end
end
