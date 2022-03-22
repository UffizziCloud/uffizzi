# frozen_string_literal: true

class UffizziCore::ComposeFile::Builders::TemplateBuilderService
  attr_accessor :credentials, :project, :repositories

  def initialize(credentials, project, repositories = [])
    @credentials = credentials
    @project = project
    @repositories = repositories
  end

  def build_attributes(compose_data, compose_dependencies, source)
    containers_data = compose_data[:containers]
    ingress_data = compose_data[:ingress]
    continuous_preview_global_data = compose_data[:continuous_preview]

    containers_attributes = build_containers_attributes(
      containers_data,
      ingress_data,
      continuous_preview_global_data,
      compose_dependencies,
    )

    {
      name: source,
      payload: {
        containers_attributes: containers_attributes,
      },
    }
  end

  private

  def build_containers_attributes(containers_data, ingress_data, continuous_preview_global_data, compose_dependencies)
    containers_data.map do |container_data|
      container_attributes(container_data, ingress_data, continuous_preview_global_data, compose_dependencies)
    end
  end

  def container_attributes(containers_data, ingress_data, continuous_preview_global_data, compose_dependencies)
    builder = UffizziCore::ComposeFile::Builders::ContainerBuilderService.new(credentials, project, repositories)

    builder.build_attributes(containers_data, ingress_data, continuous_preview_global_data, compose_dependencies)
  end
end
