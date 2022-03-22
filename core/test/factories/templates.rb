# frozen_string_literal: true

FactoryBot.define do
  factory :template, class: UffizziCore::Template do
    name
    project { nil }
    added_by_id { nil }
    creation_source { UffizziCore::Template.creation_source.manual }

    trait :compose_file_source do
      creation_source { UffizziCore::Template.creation_source.compose_file }
    end
  end
end
