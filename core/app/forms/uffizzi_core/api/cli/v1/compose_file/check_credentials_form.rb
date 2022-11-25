# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::CheckCredentialsForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

  attribute :compose_file
  attribute :credentials

  validate :check_containers_credentials

  private

  def check_containers_credentials
    compose_content = Base64.decode64(compose_file.content)
    compose_payload = { compose_file: compose_file }
    compose_data = UffizziCore::ComposeFileService.parse(compose_content, compose_payload)

    containers = compose_data[:containers]
    containers.map do |container|
      container_registry_service = UffizziCore::ContainerRegistryService.init_by_container(container)
      credential = container_registry_service.credential(credentials)
      next credential if container_registry_service.image_available?(credentials)

      raise UffizziCore::ComposeFile::CredentialError.new(I18n.t('compose.unprocessable_image', value: container_registry_service.type))
    end
  rescue UffizziCore::ComposeFile::CredentialError => e
    errors.add(:credentials, e.message)
  rescue UffizziCore::ComposeFile::ParseError => e
    errors.add(:compose_file, e.message)
  end
end
