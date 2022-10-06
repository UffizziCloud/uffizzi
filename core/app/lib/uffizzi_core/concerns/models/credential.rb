# frozen_string_literal: true

module UffizziCore::Concerns::Models::Credential
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    include AASM
    include UffizziCore::CredentialRepo
    extend Enumerize

    self.table_name = UffizziCore.table_names[:credentials]

    const_set(:CREDENTIAL_TYPES, [
                UffizziCore::Credential::Amazon.name,
                UffizziCore::Credential::Azure.name,
                UffizziCore::Credential::DockerHub.name,
                UffizziCore::Credential::DockerRegistry.name,
                UffizziCore::Credential::GithubContainerRegistry.name,
                UffizziCore::Credential::Google.name,
                UffizziCore::Credential::Github.name,
              ])

    enumerize :type,
              in: self::CREDENTIAL_TYPES, i18n_scope: ['enumerize.credential.type']

    belongs_to :account

    before_destroy :remove_token

    validates :registry_url, presence: true

    aasm :state, column: :state do
      state :not_connected, initial: true
      state :active
      state :unauthorized

      event :activate do
        transitions from: [:not_connected, :unauthorized], to: :active
      end

      event :unauthorize do
        transitions from: [:not_connected, :active], to: :unauthorized
      end

      event :disconnect do
        transitions from: [:active, :unauthorized], to: :not_connected
      end
    end

    def github_container_registry?
      type == UffizziCore::Credential::GithubContainerRegistry.name
    end

    def docker_hub?
      type == UffizziCore::Credential::DockerHub.name
    end

    def docker_registry?
      type == UffizziCore::Credential::DockerRegistry.name
    end

    def azure?
      type == UffizziCore::Credential::Azure.name
    end

    def google?
      type == UffizziCore::Credential::Google.name
    end

    def amazon?
      type == UffizziCore::Credential::Amazon.name
    end

    private

    def remove_token
      account.projects.find_each do |project|
        project.deployments.find_each do |deployment|
          containers = deployment.containers
          attributes = { continuously_deploy: UffizziCore::Container::STATE_CD_DISABLED }

          containers.with_docker_hub_repo.update_all(attributes) if docker_hub?
        end
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
