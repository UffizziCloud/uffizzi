# frozen_string_literal: true

class UffizziCore::Account < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::Account

  belongs_to :owner, class_name: UffizziCore::User.name, foreign_key: :owner_id

  aasm(:state) do
    state :active, initial: true
    state :payment_issue
    state :disabled
    state :draft

    event :activate do
      transitions from: [:payment_issue, :disabled, :draft], to: :active
    end

    event :raise_payment_issue, before_success: :update_payment_issue_date do
      transitions from: [:active, :disabled], to: :payment_issue
    end

    event :disable, after: :disable_projects do
      transitions from: [:active, :payment_issue], to: :disabled
    end
  end
end
