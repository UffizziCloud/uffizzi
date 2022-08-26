# frozen_string_literal: true

module UffizziCore::Concerns::Models::UserProject
  extend ActiveSupport::Concern

  included do
    extend Enumerize

    self.table_name = UffizziCore.table_names[:user_projects]

    enumerize :role, in: UffizziCore.user_project_roles, predicates: true, scope: true
    validates :role, presence: true

    belongs_to :user
    belongs_to :project
    belongs_to :invited_by, class_name: UffizziCore::User.name, foreign_key: :invited_by_id, optional: true
  end
end
