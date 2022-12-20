# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::CheckCredentialsForm
  include UffizziCore::ApplicationFormWithoutActiveRecord
  include UffizziCore::FormUtils

  attr_reader :type

  attribute :compose_file
  attribute :credentials

  validate :check_containers_credentials

  private

  def check_containers_credentials
    compose_content = Base64.decode64(compose_file.content)
    compose_payload = { compose_file: compose_file }
    compose_data = UffizziCore::ComposeFileService.parse(compose_content, compose_payload)

    containers = compose_data[:containers]
    containers.each do |container|
      container_registry_service = UffizziCore::ContainerRegistryService.init_by_container(container)
      @type = container_registry_service.type
      next if container_registry_service.image_available?(credentials)

      raise UffizziCore::ComposeFile::CredentialError.new(I18n.t('compose.unprocessable_image', value: type))
    end
  rescue UffizziCore::ComposeFile::CredentialError => e
    errors.add(:credentials, e.message)
  rescue UffizziCore::ContainerRegistryError => e
    if e.generic?
      errors.add(:credentials, I18n.t('compose.unprocessable_image', value: type))
      return
    end

    fill_errors_with_json_from_error_message(e.message)
  end
end
