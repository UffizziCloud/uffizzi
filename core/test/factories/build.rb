# frozen_string_literal: true

FactoryBot.define do
  factory :build, class: UffizziCore::Build do
    build_id { generate(:token) }
    repo { nil }
    repository { nil }
    branch { nil }
    commit { nil }
    committer { nil }
    message { nil }
    log_url { nil }
    status { nil }
    started_at { nil }
    ended_at { nil }
    deployed { false }

    trait :successful do
      status { UffizziCore::Build::SUCCESS }
    end

    trait :building do
      status { UffizziCore::Build::BUILDING }
    end

    trait :deployed do
      deployed { true }
    end
  end
end
