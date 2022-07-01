# frozen_string_literal: true

module UffizziCore::Concerns::Models::User
  extend ActiveSupport::Concern

  included do
    include AASM
    include ActiveModel::Validations
    include UffizziCore::StateMachineConcern
    include UffizziCore::HashidConcern
    include UffizziCore::UserRepo
    extend Enumerize

    self.table_name = UffizziCore.table_names[:users]

    rolify({ role_cname: UffizziCore::Role.name, role_join_table_name: UffizziCore.table_names[:users_roles] })

    has_many :memberships, dependent: :destroy
    has_many :accounts, through: :memberships
    has_many :user_projects, dependent: :destroy
    has_many :projects, through: :user_projects

    has_one_attached :avatar

    enumerize :creation_source, in: UffizziCore.user_creation_sources, predicates: true

    def organizational_account
      accounts.find_by(kind: UffizziCore::Account.kind.organizational)
    end

    def active_projects
      projects.active
    end

    def deployments
      UffizziCore::Deployment.where(project_id: active_projects)
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    aasm(:state) do
      state :initial, initial: true
      state :active
      state :disabled

      event :activate do
        transitions from: [:initial, :disabled], to: :active
      end

      event :disable do
        transitions from: [:initial, :active], to: :disabled
      end
    end

    def admin_access_to_project?(project)
      projects.by_ids(project).by_accounts(memberships.by_role_admin.select(:account_id)).exists?
    end
  end
end
