# frozen_string_literal: true

FactoryBot.define do
  factory :container, class: UffizziCore::Container do
    image
    tag
    variables { nil }
    secret_variables { nil }
    deployment
    repo { nil }
    receive_incoming_requests { false }
    entrypoint { nil }
    command { nil }
    continuously_deploy { UffizziCore::Container::STATE_DISABLED }

    trait :continuously_deploy_enabled do
      continuously_deploy { UffizziCore::Container::STATE_ENABLED }
    end

    trait :with_public_port do
      public { true }

      port
    end

    trait :continuously_deploy_enabled do
      continuously_deploy { UffizziCore::Container::STATE_ENABLED }
    end

    trait :continuously_deploy_disabled do
      continuously_deploy { UffizziCore::Container::STATE_DISABLED }
    end

    initialize_with { new }

    trait :active do
      state { UffizziCore::Container::STATE_ACTIVE }
    end
  end
end
