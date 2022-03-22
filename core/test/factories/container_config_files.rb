# frozen_string_literal: true

FactoryBot.define do
  factory :container_config_file, class: UffizziCore::ContainerConfigFile do
    mount_path { generate(:path) }
    container { nil }
    config_file { nil }
  end
end
