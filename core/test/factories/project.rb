# frozen_string_literal: true

FactoryBot.define do
  factory :project, class: UffizziCore::Project do
    name { generate :name }
    slug { generate :slug }
    description { generate :description }
    account
    secrets { nil }

    trait :with_members do
      transient do
        members { [] }
      end

      after(:create) do |project, evaluator|
        evaluator.members.each do |member|
          account = project.account
          invitation = account.invitations.accepted.find_by(invitee: member)

          project.user_projects.create(
            user: member,
            invited_by: account.owner,
            role: invitation.role,
          )
        end
      end
    end
  end
end
