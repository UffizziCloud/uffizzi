# frozen_string_literal: true

puts 'Creating User'

user = UffizziCore::User.create!(
  email: 'admin@uffizzi.com',
  password: 'password',
  state: UffizziCore::User::STATE_ACTIVE,
  creation_source: UffizziCore::User.creation_source.system,
)

puts 'Creating Accounts'

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

puts 'Creating Kubernetes Distributions'

UffizziCore::KubernetesDistribution.create(distro: 'k3s', version: '1.25', image: 'rancher/k3s:v1.25.14-k3s1')
UffizziCore::KubernetesDistribution.create(distro: 'k3s', version: '1.26', image: 'rancher/k3s:v1.26.9-k3s1')
UffizziCore::KubernetesDistribution.create(distro: 'k3s', version: '1.27', default: true, image: 'rancher/k3s:v1.27.6-k3s1')
UffizziCore::KubernetesDistribution.create(distro: 'k3s', version: '1.28', image: 'rancher/k3s:v1.28.2-k3s1')
