# frozen_string_literal: true

# @model Deployment
#
# @property id [integer]
# @property project_id [integer]
# @property kind [string]
# @property state [string]
# @property preview_url [string]
# @property tag [string]
# @property branch [string]
# @property commit [string]
# @property image_id [string]
# @property created_at [date-time]
# @property updated_at [date-time]
# @property ingress_container_ready [boolean]
# @property ingress_container_state [string]
# @property creation_source [string]
# @property contaners [array]
# @property deployed_by [object]

class UffizziCore::Deployment < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::Deployment
end
