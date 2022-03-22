# frozen_string_literal: true

class UffizziCore::UserProject < UffizziCore::ApplicationRecord
  extend Enumerize

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:user_projects]

  enumerize :role, in: [:admin, :developer, :viewer], predicates: true
  validates :role, presence: true

  belongs_to :user
  belongs_to :project
  belongs_to :invited_by, class_name: UffizziCore::User.name, foreign_key: :invited_by_id, optional: true
end
