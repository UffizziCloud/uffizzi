# frozen_string_literal: true

module UffizziCore::RepoService
  class << self
    def needs_target_port?(repo)
      return false if repo.nil?

      !repo.dockerfile?
    end

    def credential(repo)
      credentials = repo.project.account.credentials

      case repo.type
      when UffizziCore::Repo::GithubContainerRegistry.name
        credentials.github_container_registry.first
      when UffizziCore::Repo::DockerHub.name
        credentials.docker_hub.first
      when UffizziCore::Repo::Azure.name
        credentials.azure.first
      when UffizziCore::Repo::Google.name
        credentials.google.first
      when UffizziCore::Repo::Amazon.name
        credentials.amazon.first
      end
    end

    def image_name(repo)
      "e#{repo.container.deployment_id}r#{repo.id}-#{Digest::SHA256.hexdigest("#{self.class}:#{repo.branch}:
      #{repo.project_id}:#{repo.id}")[0, 10]}"
    end

    def tag(repo)
      repo&.builds&.deployed&.last&.commit || 'latest'
    end

    def image(repo)
      repo_credential = credential(repo)

      "#{repo_credential.registry_url}/#{image_name(repo)}"
    end
  end
end
