# frozen_string_literal: true

module UffizziCore::CredentialRepo
  extend ActiveSupport::Concern

  included do
    scope :docker_hub, -> {
      where(type: UffizziCore::Credential::DockerHub.name)
    }

    scope :github, -> {
      where(type: UffizziCore::Credential::Github.name)
    }

    scope :azure, -> {
      where(type: UffizziCore::Credential::Azure.name)
    }

    scope :google, -> {
      where(type: UffizziCore::Credential::Google.name)
    }

    scope :deployable, -> {
      where(type: [
              UffizziCore::Credential::DockerHub.name,
              UffizziCore::Credential::Azure.name,
              UffizziCore::Credential::Google.name,
              UffizziCore::Credential::Amazon.name,
              UffizziCore::Credential::GithubContainerRegistry.name,
            ])
    }

    scope :amazon, -> {
      where(type: UffizziCore::Credential::Amazon.name)
    }

    scope :github_container_registry, -> {
      where(type: UffizziCore::Credential::GithubContainerRegistry.name)
    }
  end
end
