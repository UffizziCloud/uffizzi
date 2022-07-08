# frozen_string_literal: true

module UffizziCore::DeploymentRepo
  extend ActiveSupport::Concern

  included do
    scope :with_name, ->(name) {
      where(name: name)
    }
    scope :with_amazon_repos, -> { includes(containers: [:repo]).where(containers: { repos: { type: UffizziCore::Repo::Amazon.name } }) }
    scope :existed, -> { where(state: [:active, :failed]) }
  end
end
