# frozen_string_literal: true

module UffizziCore::DependencyInjectionConcern
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

  def deployment_module
    return unless module_exists?(:deployment_module)

    module_class(:deployment_module)
  end

  def default_cli_deployment_creation_source
    creation_source = UffizziCore.dependencies[:default_cli_deployment_creation_source]
    return UffizziCore::Deployment.creation_source.compose_file_manual if creation_source.nil?

    UffizziCore::Deployment.creation_source.public_send(creation_source)
  end

  private

  def module_exists?(module_name)
    module_class(module_name).present?
  end

  def module_class(module_name)
    UffizziCore.dependencies[module_name]&.constantize
  end
end
