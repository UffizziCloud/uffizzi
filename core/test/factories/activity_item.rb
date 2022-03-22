# frozen_string_literal: true

FactoryBot.define do
  factory :activity_item, class: UffizziCore::ActivityItem do
    deployment { nil }
    namespace
    name
    tag { '' }
    branch { '' }
    container { nil }
    commit
    commit_message
    build_id { nil }

    trait :with_building_event do
      after(:create) do |activity_item, _evaluator|
        activity_item.events.create(state: UffizziCore::Event.state.building)
      end
    end

    trait :with_deploying_event do
      after(:create) do |activity_item, _evaluator|
        activity_item.events.create(state: UffizziCore::Event.state.deploying)
      end
    end

    trait :with_deployed_event do
      after(:create) do |activity_item, _evaluator|
        activity_item.events.create(state: UffizziCore::Event.state.deployed)
      end
    end

    trait :with_failed_event do
      after(:create) do |activity_item, _evaluator|
        activity_item.events.create(state: UffizziCore::Event.state.failed)
      end
    end

    trait :docker do
      type { UffizziCore::ActivityItem::Docker.name }
    end

    trait :github do
      type { UffizziCore::ActivityItem::Github.name }
    end

    trait :memory_limit do
      type { UffizziCore::ActivityItem::MemoryLimit.name }
    end
  end
end
