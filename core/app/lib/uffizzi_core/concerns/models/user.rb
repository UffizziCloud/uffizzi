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
    has_many :deployments, class_name: UffizziCore::Deployment.name, foreign_key: :deployed_by_id, dependent: :nullify
    has_many :clusters, foreign_key: :deployed_by_id

    has_one_attached :avatar

    enumerize :creation_source, in: UffizziCore.user_creation_sources, predicates: true

    def default_account
      personal_account
    end

    def personal_account
      accounts.personal.find_by(owner_id: id)
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
      project.user_projects.where(user_id: id, role: UffizziCore::UserProject.role.admin).exists?
    end
  end
end
