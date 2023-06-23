# frozen_string_literal: true

module UffizziCore::DependencyInjectionConcern
  extend ActiveSupport::Concern

  class_methods do
    def include_module_if_exists(module_name)
      include(Object.const_get(module_name)) if Object.const_defined?(module_name)
    end
  end

  def user_access_module
    return unless module_exists?(:rbac)

    UffizziCore::UserAccessService.new(module_class(:rbac))
  end

  def find_build_parser_module
    module_class(:build_parser)
  end

  def find_volume_parser_module
    module_class(:volume_parser)
  end

  def ci_session
    return unless module_exists?(:ci_session)

    module_class(:ci_session)
  end

  def password_protection_module
    return unless module_exists?(:password_protection)

    module_class(:password_protection)
  end

  def find_ingress_parser_module
    module_class(:ingress_parser)
  end

  def notification_module
    return unless module_exists?(:notification_module)

    module_class(:notification_module)
  end

  def domain_module
    return unless module_exists?(:domain_module)

    module_class(:domain_module)
  end

  def access_token_module
    return unless module_exists?(:token_module)

    module_class(:token_module)
  end

  private

  def module_exists?(module_name)
    module_class(module_name).present?
  end

  def module_class(module_name)
    UffizziCore.dependencies[module_name]&.constantize
  end
end
