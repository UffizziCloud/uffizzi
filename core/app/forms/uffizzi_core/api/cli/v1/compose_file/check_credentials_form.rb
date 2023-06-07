# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::CheckCredentialsForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

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
      container_registry_service = UffizziCore::ContainerRegistryService.init_by_container(container, credentials)
      @type = container_registry_service.type
      next if container_registry_service.image_available?(credentials)

      raise UffizziCore::ComposeFile::CredentialError.new(I18n.t('compose.unprocessable_image', value: type))
    end
  rescue UffizziCore::ContainerRegistryError => e
    errors.add(:credentials, I18n.t('compose.unprocessable_image', value: type))
    errors.add(e.error_key, e.message)
  rescue UffizziCore::ComposeFile::CredentialError => e
    errors.add(:credentials, e.message)
  end
end
