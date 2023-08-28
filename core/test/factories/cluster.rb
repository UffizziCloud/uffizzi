# frozen_string_literal: true

FactoryBot.define do
  factory :cluster, class: UffizziCore::Cluster do
    name { generate(:cluster_name) }
    project { nil }
    deployed_by { nil }

    trait :deployed do
      state { :deployed }
    end
  end
end
