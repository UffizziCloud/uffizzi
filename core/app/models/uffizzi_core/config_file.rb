# frozen_string_literal: true

# @model
#
# @property filename [string]
# @property kind [string]
# @property payload [string]
# @property source [string]

class UffizziCore::ConfigFile < UffizziCore::ApplicationRecord
  include UffizziCore::ConfigFileRepo
  extend Enumerize

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:config_files]

  belongs_to :project
  belongs_to :added_by, class_name: UffizziCore::User.name, foreign_key: :added_by_id, optional: true
  belongs_to :compose_file, optional: true

  has_many :container_config_files, dependent: :destroy

  enumerize :kind, in: [:config_map, :secret], default: :config_map, predicates: true
  enumerize :creation_source, in: [:manual, :compose_file, :system], predicates: true, scope: true
end
