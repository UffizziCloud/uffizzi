# frozen_string_literal: true

FactoryBot.define do
  factory :repo, class: UffizziCore::Repo do
    namespace
    name { generate(:string) }
    tag
    slug
    branch
    description
    repository_id { generate(:number) }
    deploy_preview_when_pull_request_is_opened { false }
    delete_preview_when_pull_request_is_closed { false }
    deploy_preview_when_image_tag_is_created { false }
    delete_preview_when_image_tag_is_updated { false }
    delete_preview_after { nil }
    share_to_github { false }

    trait :docker_hub do
      type { UffizziCore::Repo::DockerHub.name }
    end

    trait :github do
      type { UffizziCore::Repo::Github.name }
    end

    trait :azure do
      type { UffizziCore::Repo::Azure.name }
    end

    trait :google do
      type { UffizziCore::Repo::Google.name }
    end

    trait :amazon do
      type { UffizziCore::Repo::Amazon.name }
    end

    trait :kind_barestatic do
      kind { UffizziCore::Repo.kind.barestatic }
    end

    trait :kind_buildpacks18 do
      kind { UffizziCore::Repo.kind.buildpacks18 }
    end

    trait :kind_dockerfile do
      kind { UffizziCore::Repo.kind.dockerfile }
    end
  end
end
