# frozen_string_literal: true

module UserAccessService
  class << self
    def admin_access_to_account?(_user, _account)
      true
    end

    def developer_access_to_account?(_user, _account)
      true
    end

    def viewer_access_to_account?(_user, _account)
      true
    end

    def admin_or_developer_access_to_account?(_user, _account)
      true
    end

    def any_access_to_account?(_user, _account)
      true
    end

    def admin_access_to_project?(_user, _project)
      true
    end

    def developer_access_to_project?(_user, _project)
      true
    end

    def viewer_access_to_project?(_user, _project)
      true
    end

    def admin_or_developer_access_to_project?(_user, _project)
      true
    end

    def any_access_to_project?(_user, _project)
      true
    end

    def global_admin?(_user)
      true
    end
  end
end
