# frozen_string_literal: true

FactoryBot.define do
  factory :invitation, class: UffizziCore::Invitation do
    email
    token { SecureRandom.hex }
    status { UffizziCore::Invitation::STATE_PENDING }
    role { nil }
    invited_by { nil }
    entityable { nil }

    trait :accepted do
      status { UffizziCore::Invitation::STATE_ACCEPTED }
    end
    trait :admin do
      role { UffizziCore::Invitation.role.admin }
    end
    trait :developer do
      role { UffizziCore::Invitation.role.developer }
    end
    trait :viewer do
      role { UffizziCore::Invitation.role.viewer }
    end
  end
end
