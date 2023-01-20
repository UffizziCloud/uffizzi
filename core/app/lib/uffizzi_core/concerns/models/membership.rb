# frozen_string_literal: true

module UffizziCore::Concerns::Models::Membership
  extend ActiveSupport::Concern

  included do
    include AASM
    include UffizziCore::StateMachineConcern
    include UffizziCore::MembershipRepo
    extend Enumerize

    self.table_name = UffizziCore.table_names[:memberships]

    enumerize :role, in: [:admin, :developer, :viewer], predicates: true
    validates :role, presence: true

    belongs_to :account
    belongs_to :user

    validates :role, presence: true

    aasm(:state) do
      state :active, initial: true
      state :blocked

      event :activate do
        transitions from: [:blocked], to: :active
      end

      event :block do
        transitions from: [:active], to: :blocked
      end
    end
  end
end
