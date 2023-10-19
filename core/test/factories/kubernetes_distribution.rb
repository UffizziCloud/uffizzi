# frozen_string_literal: true

FactoryBot.define do
  factory :kubernetes_distribution, class: UffizziCore::KubernetesDistribution do
    version { generate(:version) }
    image { generate(:string) }
    distro { generate(:string) }

    trait :default do
      default { true }
    end
  end
end
