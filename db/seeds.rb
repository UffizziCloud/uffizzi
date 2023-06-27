# frozen_string_literal: true

user = UffizziCore::User.create!(
  email: 'admin@uffizzi.com',
  password: 'password',
  state: UffizziCore::User::STATE_ACTIVE,
  creation_source: UffizziCore::User.creation_source.system,
)

personal_account = UffizziCore::Account.create!(
  owner: user,
  name: 'personal',
  state: UffizziCore::Account::STATE_ACTIVE,
  kind: UffizziCore::Account.kind.personal,
)

organizational_account = UffizziCore::Account.create!(
  owner: user,
  name: 'organizational',
  state: UffizziCore::Account::STATE_ACTIVE,
  kind: UffizziCore::Account.kind.organizational,
)

user.memberships.create!(account: personal_account, role: UffizziCore::Membership.role.admin)
user.memberships.create!(account: organizational_account, role: UffizziCore::Membership.role.admin)

personal_project = personal_account.projects.create!(name: 'default', slug: 'default', state: UffizziCore::Project::STATE_ACTIVE)
personal_project.user_projects.create!(user: user, role: UffizziCore::UserProject.role.admin)

organizational_project = organizational_account.projects.create!(name: 'uffizzi', slug: 'uffizzi',
                                                                 state: UffizziCore::Project::STATE_ACTIVE)
organizational_project.user_projects.create!(user: user, role: UffizziCore::UserProject.role.admin)
