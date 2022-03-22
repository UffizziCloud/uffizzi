# frozen_string_literal: true

FactoryBot.define do
  factory :deployment, class: UffizziCore::Deployment do
    kind { nil }
    subdomain { generate :subdomain_name }
    created_at { DateTime.current }
    memory_limit { 1 }
    continuous_preview_payload { nil }
    creation_source { nil }

    trait :active do
      state { :active }
    end

    trait :disabled do
      state { :disabled }
    end

    trait :compose_file_source do
      creation_source { UffizziCore::Deployment.creation_source.compose_file_manual }
    end
  end
end
