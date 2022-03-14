# frozen_string_literal: true

module UffizziCore::RepoRepo
  extend ActiveSupport::Concern

  included do
    scope :docker_hub, -> { where(type: UffizziCore::Repo::DockerHub.name) }
    scope :github, -> { where(type: UffizziCore::Repo::Github.name) }
  end
end
