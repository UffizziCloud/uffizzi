# frozen_string_literal: true

module UffizziCore::Concerns::Models::HostVolumeFile
  extend ActiveSupport::Concern

  included do
    include UffizziCore::HostVolumeFileRepo

    self.table_name = UffizziCore.table_names[:host_volume_files]

    belongs_to :project
    belongs_to :added_by, class_name: UffizziCore::User.name, foreign_key: :added_by_id, optional: true
    belongs_to :compose_file, optional: true

    has_many :container_host_volume_files, dependent: :destroy

    validates :source, presence: true
    validates :path, presence: true
    validates :payload, presence: true
    validates :is_file, inclusion: [true, false]
  end
end
