# frozen_string_literal: true

class UffizziCore::User < ActiveRecord::Base
  include AASM
  include ActiveModel::Validations
  include UffizziCore::StateMachineConcern
  include UffizziCore::HashidConcern
  include UffizziCore::UserRepo
  extend Enumerize

  self.table_name = UffizziCore.table_names[:users]

  rolify

  has_secure_password

  validates :email, presence: true, 'uffizzi_core/email': true, uniqueness: { case_sensitive: false }
  validates :password, allow_nil: true, length: { minimum: 8 }, on: :update

  has_many :memberships, dependent: :destroy
  has_many :accounts, through: :memberships
  has_many :user_projects
  has_many :projects, through: :user_projects

  has_one_attached :avatar

  enumerize :creation_source, in: [:system, :online_registration, :google, :sso], predicates: true

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
