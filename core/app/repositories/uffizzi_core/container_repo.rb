# frozen_string_literal: true

module UffizziCore::ContainerRepo
  extend ActiveSupport::Concern

  included do
    include UffizziCore::BasicOrderRepo

    scope :with_amazon_repo, -> { includes(:repo).where(repo: { type: UffizziCore::Repo::Amazon.name }) }
    scope :with_docker_hub_repo, -> { includes(:repo).where(repo: { type: UffizziCore::Repo::DockerHub.name }) }

    scope :with_public_access, -> {
      where(public: true)
    }

    scope :by_repo_type, ->(type) {
      includes(:repo).where(repo: { type: type })
    }
  end
end
