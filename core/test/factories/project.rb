# frozen_string_literal: true

FactoryBot.define do
  factory :project, class: UffizziCore::Project do
    name { generate :name }
    slug { generate :slug }
    description { generate :description }
    account

    trait :with_members do
      transient do
        members { [] }
      end

      after(:create) do |project, evaluator|
        evaluator.members.each do |member|
          account = project.account
          role = account.memberships.find_by(user_id: member.id).role

          project.user_projects.create(
            user: member,
            invited_by: account.owner,
            role: role,
          )
        end
      end
    end
  end
end
