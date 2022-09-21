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
                'UffizziCore::Credential::Amazon',
                'UffizziCore::Credential::Azure',
                'UffizziCore::Credential::DockerHub',
                'UffizziCore::Credential::DockerRegistry',
                'UffizziCore::Credential::GithubContainerRegistry',
                'UffizziCore::Credential::Google',
              ])

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

    UffizziCore::ContainerRegistryService.sources.each do |t|
      define_method :"#{t}?" do
        type == "UffizziCore::Credential::#{t.to_s.camelize}"
      end
    end

    def correct?
      credential = self
      return false unless credential

      container_registry_service = UffizziCore::ContainerRegistryService.init_by_subclass(credential.type)
      status = container_registry_service.credential_correct?(credential)

      if credential.persisted? && credential.active? && !status
        Rails.logger.warn("Wrong credential: credential_correct? credential_id=#{credential.id}")
      end

      status
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
