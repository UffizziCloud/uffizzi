# frozen_string_literal: true

FactoryBot.define do
  factory :container, class: UffizziCore::Container do
    image
    tag
    service_name
    variables { nil }
    secret_variables { nil }
    deployment
    repo { nil }
    receive_incoming_requests { false }
    entrypoint { nil }
    command { nil }
    continuously_deploy { UffizziCore::Container::STATE_DISABLED }
    healthcheck { nil }
    volumes { nil }

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

    trait :with_named_volume do
      volumes do
        [
          {
            source: generate(:string),
            target: generate(:path),
            type: UffizziCore::ComposeFile::Parsers::Services::VolumesParserService::NAMED_VOLUME_TYPE,
          },
        ]
      end
    end
  end
end
