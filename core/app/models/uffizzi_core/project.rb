# frozen_string_literal: true

# @model Project
# @property slug [string]
# @property name [string]
# @property description [string]
# @property created_at [date-time]
# @property secrets [string]
# @property default_compose [object<source: string>]
# @property deployments [object<id: integer, domain: string>]
# @property account [object<id: integer, kind: string, state: string>]

class UffizziCore::Project < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::Project
end
