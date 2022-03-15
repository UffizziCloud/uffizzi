# frozen_string_literal: true

module UffizziCore::ComposeFileService
  class << self
    def has_secret?(compose_file, secret)
      containers = compose_file.template.payload['containers_attributes']

      containers.any? { |container| UffizziCore::ComposeFile::ContainerService.has_secret?(container, secret) }
    end

    def update_secret!(compose_file, secret)
      compose_file.template.payload['containers_attributes'].map do |container|
        if UffizziCore::ComposeFile::ContainerService.has_secret?(container, secret)
          container = UffizziCore::ComposeFile::ContainerService.update_secret(container, secret)
        end

        container
      end

      compose_file.template.save!

      compose_file
    end

    def secrets_valid?(compose_file, secrets)
      secret_names = secrets.pluck('name')

      compose_file.template.payload['containers_attributes'].all? do |container|
        container['secret_variables'].all? { |secret| secret_names.include?(secret['name']) }
      end
    end
  end
end
