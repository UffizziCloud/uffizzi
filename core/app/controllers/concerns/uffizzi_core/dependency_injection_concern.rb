# frozen_string_literal: true

module UffizziCore::DependencyInjectionConcern
  def user_access_module
    return unless module_defined?(:rbac)

    module_class(:rbac).new
  end

  private

  def module_defined?(module_name)
    defined?(module_class(module_name))
  end

  def module_class(module_name)
    Rails.application.config.uffizzi_core[:module_classes][module_name]
  end
end
