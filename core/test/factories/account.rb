# frozen_string_literal: true

FactoryBot.define do
  factory :account, class: UffizziCore::Account do
    name
    kind { UffizziCore::Account.kind.organizational }
    customer_token { nil }
    subscription_token { nil }
    state { nil }
    payment_issue_at { nil }
    owner { nil }
    created_at
    domain

    trait :with_admin do
      transient do
        admin { nil }
      end

      before(:create) do |account, evaluator|
        account.owner = evaluator.admin
      end

      after(:create) do |account, evaluator|
        if evaluator.admin
          invitation = account.invitations.create(
            token: UffizziCore::TokenService.generate,
            role: UffizziCore::Invitation.role.admin,
            email: evaluator.admin.email,
            invited_by: evaluator.admin,
          )

          user = evaluator.admin
          user.memberships.create(user: user, account: account, role: invitation.role)

          account.projects.each do |project|
            user.user_projects.create!(user: user, project: project, role: UffizziCore::UserProject.role.admin)
          end

          invitation.accept
          invitation.invitee = user
          invitation.save!
        end
      end
    end

    trait :organizational_account do
      kind { UffizziCore::Account.kind.organizational }
    end

    trait :with_stripe_enitities do
      after(:create) do |account, _evaluator|
        if account
          UffizziCore::StripeService.create_customer(account)
          UffizziCore::StripeService.create_subscription(account)
        end
      end
    end

    trait :disabled do
      state { :disabled }
    end

    trait :payment_issue do
      state { :payment_issue }
    end

    trait :draft do
      state { UffizziCore::Account::STATE_DRAFT }
    end

    trait :sso_connection_active do
      sso_state { UffizziCore::Account::STATE_CONNECTION_ACTIVE }
    end

    trait :sso_connection_disabled do
      sso_state { UffizziCore::Account::STATE_CONNECTION_DISABLED }
    end
  end
end
