# frozen_string_literal: true

module UffizziCore::HostVolumeFileRepo
  extend ActiveSupport::Concern

  included do
    scope :by_deployment, ->(deployment) {
      select(:id)
        .joins(:container_host_volume_files)
        .where(container_host_volume_files: { container: deployment.containers })
        .distinct
    }

    scope :by_source, ->(source) {
      where(source: source)
    }
  end
end
