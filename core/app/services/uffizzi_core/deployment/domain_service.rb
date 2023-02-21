# frozen_string_literal: true

class UffizziCore::Deployment::DomainService
  class << self
    def build_subdomain(deployment)
      return build_docker_continuous_preview_subdomain(deployment) if deployment&.continuous_preview_payload&.fetch('docker', nil).present?
      return build_pull_request_subdomain(deployment) if deployment.has_pull_request_data?

      build_default_subdomain(deployment)
    rescue UffizziCore::Deployment::LabelsNotFoundError
      build_default_subdomain(deployment)
    end

    def update_subdomain!(deployment)
      deployment.subdomain = build_subdomain(deployment)
      deployment.save!
    end

    private

    def build_pull_request_subdomain(deployment)
      _, repo_name, pull_request_number = pull_request_data(deployment)
      raise UffizziCore::Deployment::LabelsNotFoundError if repo_name.nil? || pull_request_number.nil?

      formatted_repo_name = format_url_safe(repo_name.split('/').last.downcase)
      subdomain = "pr-#{pull_request_number}-#{name(deployment)}-#{formatted_repo_name}"
      format_subdomain(subdomain)
    end

    def build_docker_continuous_preview_subdomain(deployment)
      project = deployment.project
      continuous_preview_payload = deployment.continuous_preview_payload
      docker_payload = continuous_preview_payload['docker']
      repo_name = docker_payload['image'].split('/').last
      image_tag = docker_payload['tag']
      deployment_name = name(deployment)
      subdomain = "#{image_tag}-#{deployment_name}-#{repo_name}-#{project.slug}"

      format_subdomain(subdomain)
    end

    def build_default_subdomain(deployment)
      deployment_name = name(deployment)
      slug = deployment.project.slug.to_s
      subdomain = "#{deployment_name}-#{slug}"

      format_subdomain(subdomain)
    end

    def build_preview_url(deployment)
      "#{deployment.subdomain}.#{Settings.app.managed_dns_zone}"
    end

    def build_deployment_url(deployment)
      "#{Settings.app.host}/projects/#{deployment.project_id}/deployments"
    end

    def name(deployment)
      "deployment-#{deployment.id}"
    end

    def pull_request_data(deployment)
      return github_pull_request_data(deployment) if deployment.has_github_pull_request_data?

      gitlab_merge_request_data(deployment)
    end

    def github_pull_request_data(deployment)
      github_data = deployment.metadata.dig('labels', 'github')

      [:github, github_data['repository'], github_data.dig('event', 'number')]
    end

    def gitlab_merge_request_data(deployment)
      gitlab_data = deployment.metadata.dig('labels', 'gitlab')

      [:gitlab, gitlab_data['repo'], gitlab_data.dig('merge_request', 'number')]
    end

    def format_subdomain(full_subdomain_name)
      # Replace _ to - because RFC 1123 subdomain must consist of lower case alphanumeric characters,
      # '-' or '.', and must start and end with an alphanumeric character
      rfc_subdomain = full_subdomain_name.gsub('_', '-')
      subdomain_length_limit = Settings.deployment.subdomain.length_limit
      return rfc_subdomain if rfc_subdomain.length <= subdomain_length_limit

      sliced_subdomain = rfc_subdomain.slice(0, subdomain_length_limit)
      return sliced_subdomain.chop if sliced_subdomain.end_with?('-')

      sliced_subdomain
    end

    def format_url_safe(name)
      name.gsub(/ /, '-').gsub(/[^\w-]+/, '-')
    end
  end
end
