# frozen_string_literal: true

FactoryBot.define do
  factory :credential, class: UffizziCore::Credential do
    username { generate(:login) }
    password
    account { nil }
    registry_url { generate(:url) }

    trait :docker_hub do
      type { UffizziCore::Credential::DockerHub.name }
    end

    trait :github do
      type { UffizziCore::Credential::Github.name }
    end

    trait :azure do
      type { UffizziCore::Credential::Azure.name }
    end

    trait :google do
      type { UffizziCore::Credential::Google.name }
      registry_url { 'https://gcr.io/' }
    end

    trait :github_container_registry do
      type { UffizziCore::Credential::GithubContainerRegistry.name }
      registry_url { 'https://ghcr.io/' }
    end

    trait :amazon do
      type { UffizziCore::Credential::Amazon.name }
      registry_url { 'https://123456789876.dkr.ecr.us-east-1.amazonaws.com' }
    end

    trait :unauthorized do
      state { :unauthorized }
    end

    trait :active do
      state { :active }
    end
  end
end
