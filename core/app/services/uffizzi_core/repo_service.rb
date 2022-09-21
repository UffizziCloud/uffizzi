# frozen_string_literal: true

class UffizziCore::RepoService
  class << self
    def needs_target_port?(repo)
      return false if repo.nil?

      !repo.dockerfile?
    end

    def credential(repo)
      container_registry_service = UffizziCore::ContainerRegistryService.init_by_subclass(repo.type)
      credentials = repo.project.account.credentials
      container_registry_service.credential(credentials)
    end

    def image_name(repo)
      "e#{repo.container.deployment_id}r#{repo.id}-#{Digest::SHA256.hexdigest("#{self.class}:#{repo.branch}:
      #{repo.project_id}:#{repo.id}")[0, 10]}"
    end

    def image(repo)
      repo_credential = credential(repo)

      "#{repo_credential.registry_url}/#{image_name(repo)}"
    end
  end
end
