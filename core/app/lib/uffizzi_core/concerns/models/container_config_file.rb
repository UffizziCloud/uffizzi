# frozen_string_literal: true

module UffizziCore::Concerns::Models::ContainerConfigFile
  extend ActiveSupport::Concern

  included do
    self.table_name = UffizziCore.table_names[:container_config_files]

    belongs_to :container
    belongs_to :config_file
  end
end
