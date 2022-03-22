# frozen_string_literal: true

FactoryBot.define do
  factory :config_file, class: UffizziCore::ConfigFile do
    filename { generate(:name) }
    added_by { nil }
    kind { UffizziCore::ConfigFile.kind.config_map }
    payload { generate(:string) }
    project { nil }
    creation_source { UffizziCore::ConfigFile.creation_source.manual }
  end

  trait :compose_file_source do
    creation_source { UffizziCore::ConfigFile.creation_source.compose_file }
  end
end
