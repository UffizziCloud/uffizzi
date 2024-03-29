# frozen_string_literal: true

class UffizziCore::UserGeneratorService
  DEFAULT_USER_EMAIL = 'user@example.com'
  DEFAULT_PROJECT_NAME = 'default'
  DEFAULT_ACCOUNT_NAME = 'default'

  class << self
    def safe_generate(email, password, project_name)
      generate(email, password, project_name)
    rescue ActiveRecord::RecordInvalid => e
      puts e.message
    end

    def generate(email, password, project_name)
      user_attributes = build_user_attributes(email, password)
      project_attributes = build_project_attributes(project_name)

      ActiveRecord::Base.transaction do
        user = UffizziCore::User.create!(user_attributes)

        account_attributes = build_account_attributes(user)
        account = UffizziCore::Account.create!(account_attributes)
        user.memberships.create!(account: account, role: UffizziCore::Membership.role.admin)
        project = account.projects.create!(project_attributes)
        project.user_projects.create!(user: user, role: UffizziCore::UserProject.role.admin)
      end
    end

    private

    def build_user_attributes(email, password)
      user_attributes = {
        state: UffizziCore::User::STATE_ACTIVE,
        creation_source: UffizziCore::User.creation_source.system,
      }

      if email.present?
        user_attributes[:email] = email
      elsif IO::console.present?
        IO::console.write("Enter User Email (default: #{DEFAULT_USER_EMAIL}): ")
        user_attributes[:email] = IO::console.gets.strip.presence || DEFAULT_USER_EMAIL
      end

      user_attributes[:password] = if password.present?
        password
      elsif IO::console.present?
        IO::console.getpass('Enter Password: ')
      end

      user_attributes
    end

    def build_project_attributes(project_name)
      project_attributes = {
        state: UffizziCore::Project::STATE_ACTIVE,
      }
      if project_name.present?
        project_attributes[:name] = project_name
      elsif IO::console.present?
        IO::console.write("Enter Project Name (default: #{DEFAULT_PROJECT_NAME}): ")
        project_attributes[:name] = IO::console.gets.strip.presence || DEFAULT_PROJECT_NAME
      else
        project_attributes[:name] = DEFAULT_PROJECT_NAME
      end

      project_attributes[:slug] = prepare_project_slug(project_attributes[:name])
      project_attributes
    end

    def build_account_attributes(user)
      {
        owner: user,
        name: DEFAULT_ACCOUNT_NAME,
        state: UffizziCore::Account::STATE_ACTIVE,
        kind: UffizziCore::Account.kind.personal,
      }
    end

    def prepare_project_slug(project_name)
      project_name.downcase.gsub(/[^A-Za-z0-9]/, '-')
    end
  end
end
