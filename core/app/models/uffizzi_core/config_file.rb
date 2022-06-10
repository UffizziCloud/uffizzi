# frozen_string_literal: true

# @model
#
# @property filename [string]
# @property kind [string]
# @property payload [string]
# @property source [string]

class UffizziCore::ConfigFile < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::ConfigFile
end
