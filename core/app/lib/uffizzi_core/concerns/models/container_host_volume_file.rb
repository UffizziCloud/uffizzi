# frozen_string_literal: true

module UffizziCore::Concerns::Models::ContainerHostVolumeFile
  extend ActiveSupport::Concern

  included do
    self.table_name = UffizziCore.table_names[:container_host_volume_files]

    belongs_to :container
    belongs_to :host_volume_file
  end
end
