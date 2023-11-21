# frozen_string_literal: true

module UffizziCore::Concerns::Models::Deployment
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    include AASM
    include UffizziCore::StateMachineConcern
    include UffizziCore::DeploymentRepo
    extend Enumerize
    include UffizziCore::DependencyInjectionConcern

    self.table_name = UffizziCore.table_names[:deployments]

    enumerize :kind, in: [:standard], predicates: true, default: :standard

    belongs_to :project, touch: true
    belongs_to :deployed_by, class_name: UffizziCore::User.name, foreign_key: :deployed_by_id, optional: true
    belongs_to :template, optional: true
    belongs_to :compose_file, optional: true

    has_many :credentials, through: :project
    has_many :containers, dependent: :destroy, index_errors: true
    has_many :activity_items, dependent: :destroy
    has_many :deployment_events, dependent: :destroy

    has_one :ingress_container, -> { where(receive_incoming_requests: true) }, class_name: UffizziCore::Container.name
    validates :kind, presence: true

    enumerize :creation_source, in: [:manual, :demo, :continuous_preview, :compose_file_manual, :compose_file_continuous_preview,
                                     :github_actions, :gitlab_actions], predicates: true, scope: true, default: :manual

    accepts_nested_attributes_for :containers, allow_destroy: true

    after_destroy_commit :clean

    def active_containers
      containers.active
    end

    aasm(:state) do
      state :active, initial: true
      state :failed
      state :disabled

      event :activate, after: :after_activate do
        transitions from: [:disabled, :failed], to: :active
      end

      event :fail do
        transitions from: [:active], to: :failed
      end

      event :disable, after: :after_disable do
        transitions from: [:active, :failed], to: :disabled
      end
    end

    def after_activate
      update!(disabled_at: nil)
    end

    def after_disable
      clean
      update!(disabled_at: Time.now)
    end

    def clean
      active_containers.each(&:disable!)
      UffizziCore::Deployment::DeleteJob.perform_async(id)
    end

    def preview_url
      managed_dns_zone = controller_settings_service.deployment(self).managed_dns_zone
      "#{subdomain}.#{managed_dns_zone}"
    end

    def namespace
      "deployment-#{id}"
    end
  end
  # rubocop:enable Metrics/BlockLength
end
