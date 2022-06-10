# frozen_string_literal: true

module UffizziCore::Concerns::Models::ConfigFile
  extend ActiveSupport::Concern

  included do
    include UffizziCore::ConfigFileRepo
    extend Enumerize

    self.table_name = UffizziCore.table_names[:config_files]

    belongs_to :project
    belongs_to :added_by, class_name: UffizziCore::User.name, foreign_key: :added_by_id, optional: true
    belongs_to :compose_file, optional: true

    has_many :container_config_files, dependent: :destroy

    enumerize :kind, in: [:config_map, :secret], default: :config_map, predicates: true
    enumerize :creation_source, in: [:manual, :compose_file, :system], predicates: true, scope: true
  end
end
