# frozen_string_literal: true

class UffizziCore::TemplateService
  class << self
    include UffizziCore::DependencyInjectionConcern

    def valid_memory_limit?(template)
      total_memory_limit = template.payload['containers_attributes'].map { |container| container['memory_limit'] }.sum

      deployment_memory_module.valid_memory_limit?(total_memory_limit)
    end

    def valid_memory_request?(template)
      total_memory_request = template.payload['containers_attributes'].map { |container| container['memory_request'] }.sum

      deployment_memory_module.valid_memory_request?(total_memory_request)
    end
  end
end
