# frozen_string_literal: true

module UffizziCore::DeploymentRepo
  extend ActiveSupport::Concern

  included do
    scope :with_name, ->(name) {
      where(name: name)
    }
    scope :by_config_file, ->(config_file) {
      container_config_files = UffizziCore::ContainerConfigFile.where(config_file: config_file)
      containers = UffizziCore::Container.where(id: container_config_files.select(:container_id))
      where(id: containers.select(:deployment_id))
    }
    scope :with_amazon_repos, -> { includes(containers: [:repo]).where(containers: { repos: { type: UffizziCore::Repo::Amazon.name } }) }
    scope :by_templates, ->(templates) {
      where(template: templates).where.not(templates: nil)
    }
    scope :with_containers, ->(source, image, tag) {
      includes(containers: :repo).where(containers: { image: image, tag: tag, repos: { type: source } })
    }
  end
end
