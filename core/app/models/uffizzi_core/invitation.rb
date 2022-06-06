# frozen_string_literal: true

class UffizziCore::Invitation < UffizziCore::ApplicationRecord
  include AASM
  include UffizziCore::StateMachineConcern
  extend Enumerize

  self.table_name = UffizziCore.table_names[:invitations]

  enumerize :role, in: [:admin, :developer, :viewer], predicates: true

  belongs_to :entityable, polymorphic: true
  belongs_to :invited_by, class_name: UffizziCore::User.name, foreign_key: :invited_by_id
  belongs_to :invitee, class_name: UffizziCore::User.name, foreign_key: :invitee_id, optional: true

  validates :email, presence: true, 'uffizzi_core/email': true
  validates :token, presence: true, uniqueness: true

  aasm(:status) do
    state :pending, initial: true
    state :accepted

    event :accept do
      transitions from: :pending, to: :accepted
    end
  end
end
