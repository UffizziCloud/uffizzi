# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: UffizziCore::User do
    first_name
    last_name
    email
    password
    phone
    confirmation_token
    created_at
    github
    website
    twitter
    linkedin
    devto
    facebook
    blog
    bio
    status
    availability
    primary_skills
    learning
    coding_for
    education
    title
    work
    primary_location

    trait :with_organizational_account do
      after(:create) do |user, _evaluator|
        create(:account, :with_admin, kind: UffizziCore::Account.kind.organizational, admin: user, created_at: user.created_at)
      end
    end

    trait :with_organizational_account_and_stripe_enitities do
      after(:create) do |user, _evaluator|
        create(:account, :with_admin, :with_stripe_enitities, kind: UffizziCore::Account.kind.organizational, admin: user,
                                                              created_at: user.created_at)
      end
    end

    trait :active do
      state { :active }
    end

    trait :disabled do
      state { :disabled }
    end

    trait :global_admin do
      after(:create) do |user, _evaluator|
        user.add_role(:admin)
      end
    end

    trait :user_google do
      creation_source { :google }
    end

    trait :user_sso do
      creation_source { :sso }
    end

    trait :admin_in_organization do
      transient do
        organization { nil }
      end

      after(:create) do |user, evaluator|
        create(:invitation, :accepted, :admin, invitee: user, invited_by: evaluator.organization.owner, entityable: evaluator.organization)
        create(:membership, :admin, user: user, account: evaluator.organization)
      end
    end

    trait :developer_in_organization do
      transient do
        organization { nil }
      end

      after(:create) do |user, evaluator|
        create(:invitation, :accepted, :developer, invitee: user, invited_by: evaluator.organization.owner,
                                                   entityable: evaluator.organization)
        create(:membership, :developer, user: user, account: evaluator.organization)
      end
    end

    trait :viewer_in_organization do
      transient do
        organization { nil }
      end

      after(:create) do |user, evaluator|
        create(:invitation, :accepted, :viewer, invitee: user, invited_by: evaluator.organization.owner, entityable: evaluator.organization)
        create(:membership, :viewer, user: user, account: evaluator.organization)
      end
    end
  end
end
