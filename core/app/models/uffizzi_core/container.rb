# frozen_string_literal: true

# @model Container
#
# @property id [integer]
# @property name [string]
# @property memory_limit [integer]
# @property memory_request [integer]
# @property continuously_deploy [string]
# @property variables [object]
# @property secret_variables [object]
# @property container_config_files [ConfigFile]

class UffizziCore::Container < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::Container
end
