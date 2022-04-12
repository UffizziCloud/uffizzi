# frozen_string_literal: true

class UffizziCore::ContainerService
  class << self
    def pod_name(container)
      return container.controller_name if container.controller_name.present?

      formatted_name = container.image_name
      formatted_name.parameterize.gsub('_', '-')
    end

    def target_port_value(container)
      container.port
    end

    def defines_env?(container, name)
      return false if container.variables.nil?

      container.variables.select { |v| v['name'].downcase.to_sym == name.to_sym }.any?
    end

    def continuously_deploy_enabled?(container)
      container.aasm(:continuously_deploy).current_state == UffizziCore::Container::STATE_ENABLED
    end

    def valid_memory_limit?(container)
      max_memory_limit = container.deployment.project.account.container_memory_limit
      container_memory_limit = container.memory_limit
      return true if max_memory_limit.nil? || container_memory_limit.nil?

      container_memory_limit <= max_memory_limit
    end

    def valid_memory_request?(container)
      max_memory_limit = container.deployment.project.account.container_memory_limit
      container_memory_request = container.memory_request
      return true if max_memory_limit.nil? || container_memory_request.nil?

      container_memory_request <= max_memory_limit
    end
  end
end
