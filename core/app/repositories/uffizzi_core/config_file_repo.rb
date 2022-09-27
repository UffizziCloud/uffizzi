# frozen_string_literal: true

module UffizziCore::ConfigFileRepo
  extend ActiveSupport::Concern

  included do
    scope :by_deployment, ->(deployment) {
      select(:id)
        .joins(:container_config_files)
        .where(container_config_files: { container: deployment.containers })
        .distinct
    }

    scope :by_source, ->(source) {
      where(source: source)
    }
  end
end
