# frozen_string_literal: true

class UffizziCore::Account < UffizziCore::ApplicationRecord
  include AASM
  include UffizziCore::StateMachineConcern
  extend Enumerize

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:accounts]

  enumerize :kind, in: [:personal, :organizational], scope: true, predicates: true
  validates :kind, presence: true
  validates :domain, uniqueness: true, if: :domain

  belongs_to :owner, class_name: UffizziCore::User.name, foreign_key: :owner_id

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :credentials, dependent: :destroy

  has_many :projects, dependent: :destroy
  has_many :deployments, through: :projects
  has_many :payments, dependent: :destroy
  has_many :invitations, as: :entityable

  aasm(:state) do
    state :active, initial: true
    state :payment_issue
    state :disabled
    state :draft

    # next states should be removed after migration
    state :trial
    state :trial_expired
    state :past_due

    event :activate do
      transitions from: [:payment_issue, :disabled, :trial, :trial_expired, :past_due, :draft], to: :active
    end

    event :raise_payment_issue, before_success: :update_payment_issue_date do
      transitions from: [:active, :trial, :trial_expired, :past_due, :disabled], to: :payment_issue
    end

    event :disable, after: :disable_projects do
      transitions from: [:active, :trial, :trial_expired, :past_due, :payment_issue], to: :disabled
    end
  end

  aasm(:sso_state) do
    state :connection_not_configured, initial: true
    state :connection_disabled
    state :connection_active

    event :activate_connection do
      transitions from: [:connection_not_configured, :connection_disabled], to: :connection_active
    end

    event :deactivate_connection do
      transitions from: [:connection_active], to: :connection_disabled
    end

    event :reset_connection do
      transitions from: [:connection_active, :connection_disabled], to: :connection_not_configured
    end
  end

  def update_payment_issue_date
    update(payment_issue_at: DateTime.current)
  end

  def can_create_new_resources?
    return active? if Settings.features.stripe_enabled

    true
  end

  def active_projects
    projects.active
  end

  def disable_paid_deployments
    deployments.active.where('kind != ?', UffizziCore::Deployment.kind.free).each(&:disable!)
  end

  def disable_projects
    active_projects.each(&:disable_deployments)
  end

  def any_paid_projects?
    projects.any?(&:any_paid_deployments?)
  end

  def cards
    StripeService.cards(self)
  end

  #  This method is deprecated. Don't use it.
  def user
    users.find_by(memberships: { role: UffizziCore::Membership.role.admin })
  end
end
