# frozen_string_literal: true

user = UffizziCore::User.create!(
  email: 'admin@uffizzi.com',
  password: 'password',
  state: UffizziCore::User::STATE_ACTIVE,
  creation_source: UffizziCore::User.creation_source.system,
)

account = UffizziCore::Account.create!(
  owner: user,
  name: 'default',
  state: UffizziCore::Account::STATE_ACTIVE,
  kind: UffizziCore::Account.kind.organizational,
)

user.memberships.create!(account: account, role: UffizziCore::Membership.role.admin)

project = account.projects.create!(name: 'default', slug: 'default', state: UffizziCore::Project::STATE_ACTIVE)
project.user_projects.create!(user: user, role: UffizziCore::UserProject.role.admin)
