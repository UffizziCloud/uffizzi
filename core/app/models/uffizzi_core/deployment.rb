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
  include UffizziCore::DependencyInjectionConcern

  validate :check_max_memory_limit
  validate :check_max_memory_request

  def check_max_memory_limit
    return if deployment_memory_module.valid_memory_limit?(self)

    deployment_memory_module.memory_limit_error_message(self)
    errors.add(:containers, message)
  end

  def check_max_memory_request
    return if deployment_memory_module.valid_memory_request?(self)

    deployment_memory_module.memory_request_error_message(self)
    errors.add(:containers, message)
  end
end
