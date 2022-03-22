# frozen_string_literal: true

class UffizziCore::Membership < UffizziCore::ApplicationRecord
  include UffizziCore::MembershipRepo
  extend Enumerize

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:memberships]

  enumerize :role, in: [:admin, :developer, :viewer], predicates: true
  validates :role, presence: true

  belongs_to :account
  belongs_to :user

  validates :role, presence: true
end
