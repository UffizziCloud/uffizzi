# frozen_string_literal: true

FactoryBot.define do
  factory :container_host_volume_file, class: UffizziCore::ContainerHostVolumeFile do
    source_path { generate(:relative_path) }
    container { nil }
    host_volume_file { nil }
  end
end
