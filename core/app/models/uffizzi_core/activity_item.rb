# frozen_string_literal: true

# @model
#
# @property id [integer]
# @property namespace [string]
# @property name(required) [string]
# @property tag [string]
# @property branch [string]
# @property type [string]
# @property container_id [string]
# @property commit [string]
# @property commit_message [string]
# @property build_id [integer]
# @property created_at [date]
# @property updated_at [date]
# @property data [object]
# @property digest [string]
# @property meta [object]

class UffizziCore::ActivityItem < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::ActivityItem
end
