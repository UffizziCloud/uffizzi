# frozen_string_literal: true

FactoryBot.define do
  factory :compose_file, class: UffizziCore::ComposeFile do
    source { generate(:name) }
    repository_id { generate(:number) }
    branch
    path
    auto_deploy { UffizziCore::ComposeFile::STATE_DISABLED }
    kind { UffizziCore::ComposeFile.kind.main }

    trait :auto_deploy do
      auto_deploy { UffizziCore::ComposeFile::STATE_ENABLED }
    end

    trait :invalid_file do
      state { :invalid_file }
    end

    trait :temporary do
      kind { UffizziCore::ComposeFile.kind.temporary }
    end
  end
end
