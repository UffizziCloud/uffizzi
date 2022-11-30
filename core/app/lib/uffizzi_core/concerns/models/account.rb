# frozen_string_literal: true

module UffizziCore::Concerns::Models::Account
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    include AASM
    include UffizziCore::AccountRepo
    include UffizziCore::StateMachineConcern
    extend Enumerize

    self.table_name = UffizziCore.table_names[:accounts]

    enumerize :kind, in: [:personal, :organizational], scope: true, predicates: true
    validates :kind, presence: true
    validates :domain, uniqueness: true, if: :domain

    has_many :memberships, dependent: :destroy
    has_many :users, through: :memberships
    has_many :credentials, dependent: :destroy

    has_many :projects, dependent: :destroy
    has_many :deployments, through: :projects
    has_many :payments, dependent: :destroy

    aasm(:state) do
      state :trial, initial: true
      state :spent_free_limit
      state :active
      state :payment_issue
      state :disabled

      event :activate do
        transitions from: [:payment_issue, :disabled, :spent_free_limit, :trial], to: :active
      end

      event :disable_trial do
        transitions from: [:trial], to: :spent_free_limit
      end

      event :raise_payment_issue, before_success: :update_payment_issue_date do
        transitions from: [:active, :disabled], to: :payment_issue
      end

      event :disable, after: :disable_projects do
        transitions from: [:active, :payment_issue, :trial, :spent_free_limit], to: :disabled
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

    def active_projects
      projects.active
    end

    def disable_projects
      active_projects.each(&:disable_deployments)
    end

    #  This method is deprecated. Don't use it.
    def user
      users.find_by(memberships: { role: UffizziCore::Membership.role.admin })
    end
  end
  # rubocop:enable Metrics/BlockLength
end
