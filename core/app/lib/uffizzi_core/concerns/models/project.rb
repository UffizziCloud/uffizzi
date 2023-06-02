# frozen_string_literal: true

module UffizziCore::Concerns::Models::Project
  extend ActiveSupport::Concern

  included do
    include AASM
    include UffizziCore::StateMachineConcern
    include UffizziCore::ProjectRepo

    self.table_name = UffizziCore.table_names[:projects]

    belongs_to :account

    has_many :repos, dependent: :destroy
    has_many :deployments, dependent: :destroy
    has_many :user_projects, dependent: :destroy
    has_many :users, through: :user_projects
    has_many :config_files, dependent: :destroy
    has_many :templates, dependent: :destroy
    has_many :credentials, through: :account
    has_many :compose_files, dependent: :destroy
    has_many :secrets, dependent: :destroy, as: :resource
    has_many :host_volume_files, dependent: :destroy
    has_many :clusters, dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: :account, message: 'Name already exists' }
    validates :slug, presence: true, uniqueness: { message: 'Project slug already taken' }

    aasm(:state) do
      state :active, initial: true
      state :disabled

      event :activate do
        transitions from: [:disabled], to: :active
      end

      event :disable, after: :after_disable do
        transitions from: [:active], to: :disabled
      end
    end

    def after_disable
      disable_deployments
    end

    def active_deployments
      deployments.active
    end

    def disable_deployments
      active_deployments.each do |deployment|
        UffizziCore::DeploymentService.disable!(deployment)
        deployment.deployment_events.create!(deployment_state: deployment.state, message: 'Disabled after project was disabled')
      end
    end

    def compose_file
      compose_files.main.first
    end
  end
end
