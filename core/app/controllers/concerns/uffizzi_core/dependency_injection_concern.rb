# frozen_string_literal: true

module UffizziCore::DependencyInjectionConcern
  def user_access_module
    return unless module_exists?(:rbac)

    module_class(:rbac).new
  end

  private

  def module_exists?(module_name)
    module_class(module_name).present?
  end

  def module_class(module_name)
    UffizziCore.dependencies[module_name]&.constantize
  end
end
