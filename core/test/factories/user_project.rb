# frozen_string_literal: true

FactoryBot.define do
  factory :user_project, class: UffizziCore::UserProject do
    user { nil }
    project { nil }
    role { nil }

    trait :admin do
      role { UffizziCore::UserProject.role.admin }
    end
    trait :developer do
      role { UffizziCore::UserProject.role.developer }
    end
    trait :viewer do
      role { UffizziCore::UserProject.role.viewer }
    end
  end
end
