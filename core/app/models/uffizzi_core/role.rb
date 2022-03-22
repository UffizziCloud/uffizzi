# frozen_string_literal: true

class UffizziCore::Role < UffizziCore::ApplicationRecord
  self.table_name = Rails.application.config.uffizzi_core[:table_names][:roles]

  has_and_belongs_to_many :users, join_table: Rails.application.config.uffizzi_core[:table_names][:users_roles]

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify
end
