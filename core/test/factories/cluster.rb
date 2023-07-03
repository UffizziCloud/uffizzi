# frozen_string_literal: true

FactoryBot.define do
  factory :cluster, class: UffizziCore::Cluster do
    name

    trait :deployed do
      state { :deployed }
    end
  end
end
