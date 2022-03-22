# frozen_string_literal: true

class UffizziCore::TemplateService
  class << self
    def valid_containers_memory_limit?(template)
      containers_attributes = template.payload['containers_attributes']
      container_memory_limit = template.project.account.container_memory_limit
      return true if container_memory_limit.nil?

      containers_attributes.all? { |container| container['memory_limit'].to_i <= container_memory_limit }
    end

    def valid_containers_memory_request?(template)
      containers_attributes = template.payload['containers_attributes']
      container_memory_limit = template.project.account.container_memory_limit
      return true if container_memory_limit.nil?

      containers_attributes.all? { |container| container['memory_request'].to_i <= container_memory_limit }
    end
  end
end
