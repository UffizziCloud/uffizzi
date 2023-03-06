# frozen_string_literal: true

class UffizziCore::Deployment::DomainService
  class << self
    include UffizziCore::DependencyInjectionConcern

    def build_subdomain(deployment)
      return domain_module.build_subdomain(deployment) if domain_module.present?
      return build_docker_continuous_preview_subdomain(deployment) if deployment&.continuous_preview_payload&.fetch('docker', nil).present?

      build_default_subdomain(deployment)
    end

    def update_subdomain!(deployment)
      deployment.subdomain = build_subdomain(deployment)
      deployment.save!
    end

    private

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

    def name(deployment)
      "deployment-#{deployment.id}"
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
