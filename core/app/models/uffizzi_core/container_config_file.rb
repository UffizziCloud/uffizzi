# frozen_string_literal: true

class UffizziCore::ContainerConfigFile < UffizziCore::ApplicationRecord
  self.table_name = UffizziCore.table_names[:container_config_files]

  belongs_to :container
  belongs_to :config_file
end
