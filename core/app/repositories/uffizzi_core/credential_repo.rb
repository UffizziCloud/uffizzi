# frozen_string_literal: true

module UffizziCore::CredentialRepo
  extend ActiveSupport::Concern

  included do
    scope :by_type, ->(type) { where(type: type) }
    scope :docker_hub, -> { by_type(UffizziCore::Credential::DockerHub.name) }
    scope :azure, -> { by_type(UffizziCore::Credential::Azure.name) }
    scope :google, -> { by_type(UffizziCore::Credential::Google.name) }
    scope :amazon, -> { by_type(UffizziCore::Credential::Amazon.name) }
    scope :github_container_registry, -> { by_type(UffizziCore::Credential::GithubContainerRegistry.name) }
    scope :deployable, -> {
      by_type([
                UffizziCore::Credential::DockerHub.name,
                UffizziCore::Credential::Azure.name,
                UffizziCore::Credential::Google.name,
                UffizziCore::Credential::Amazon.name,
                UffizziCore::Credential::GithubContainerRegistry.name,
              ])
    }
  end
end
