# frozen_string_literal: true

FactoryBot.define do
  factory :host_volume_file, class: UffizziCore::HostVolumeFile do
    path { generate(:path) }
    source { generate(:relative_path) }
    payload { generate(:string) }
    added_by { nil }
    project { nil }
    compose_file { nil }
  end
end
