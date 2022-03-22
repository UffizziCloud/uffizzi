# frozen_string_literal: true

module UffizziCore::ContainerRepo
  extend ActiveSupport::Concern

  included do
    include UffizziCore::BasicOrderRepo

    scope :with_github_repo, -> { includes(:repo).where(repo: { type: UffizziCore::Repo::Github.name }) }
    scope :with_amazon_repo, -> { includes(:repo).where(repo: { type: UffizziCore::Repo::Amazon.name }) }
    scope :with_docker_hub_repo, -> { includes(:repo).where(repo: { type: UffizziCore::Repo::DockerHub.name }) }

    scope :with_public_access, -> {
      where(public: true)
    }

    scope :with_enabled_continuously_deploy, -> {
      where(continuously_deploy: UffizziCore::Container::STATE_ENABLED)
    }

    scope :by_repo_type, ->(type) {
      includes(:repo).where(repo: { type: type })
    }
  end
end
