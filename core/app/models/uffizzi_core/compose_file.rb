# frozen_string_literal: true

# @model ComposeFile
# @property id [integer]
# @property source [string]
# @property path [string]
# @property content(required) [string]
# @property auto_deploy [boolean]
# @property state [string]
# @property payload [string]

class UffizziCore::ComposeFile < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::ComposeFile
end
