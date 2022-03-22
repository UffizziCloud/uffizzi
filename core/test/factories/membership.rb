# frozen_string_literal: true

FactoryBot.define do
  factory :membership, class: UffizziCore::Membership do
    user { nil }
    account { nil }
    role { UffizziCore::Membership.role.developer }
    trait :admin do
      role { UffizziCore::Membership.role.admin }
    end
    trait :developer do
      role { UffizziCore::Membership.role.developer }
    end
    trait :viewer do
      role { UffizziCore::Membership.role.viewer }
    end
  end
end
