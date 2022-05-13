# frozen_string_literal: true

# @model Deployment
#
# @property id [integer]
# @property project_id [integer]
# @property kind [string]
# @property state [string]
# @property preview_url [string]
# @property tag [string]
# @property branch [string]
# @property commit [string]
# @property image_id [string]
# @property created_at [date-time]
# @property updated_at [date-time]
# @property ingress_container_ready [boolean]
# @property ingress_container_state [string]
# @property creation_source [string]
# @property contaners [array]
# @property deployed_by [object]

class UffizziCore::Deployment < UffizziCore::ApplicationRecord
  include AASM
  include UffizziCore::StateMachineConcern
  include UffizziCore::DeploymentRepo
  extend Enumerize

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:deployments]

  enumerize :kind, in: [:standard, :performance, :enterprise, :free], predicates: true, default: :standard

  belongs_to :project, touch: true
  belongs_to :deployed_by, class_name: UffizziCore::User.name, foreign_key: :deployed_by_id, optional: true
  belongs_to :template, optional: true
  belongs_to :compose_file, optional: true

  has_many :credentials, through: :project
  has_many :containers, dependent: :destroy, index_errors: true
  has_many :activity_items, dependent: :destroy

  has_one :ingress_container, -> { where(receive_incoming_requests: true) }, class_name: UffizziCore::Container.name

  validates :kind, presence: true

  enumerize :creation_source, in: [:manual, :continuous_preview, :compose_file_manual, :compose_file_continuous_preview], predicates: true,
                              scope: true, default: :manual

  accepts_nested_attributes_for :containers, allow_destroy: true

  after_destroy_commit :clean

  def active_containers
    containers.active
  end

  aasm(:state) do
    state :active, initial: true
    state :failed
    state :disabled

    event :activate do
      transitions from: [:disabled], to: :active
    end

    event :fail, after: :after_fail do
      transitions from: [:active], to: :failed
    end

    event :disable, after: :after_disable do
      transitions from: [:active, :failed], to: :disabled
    end
  end

  def after_disable
    clean
  end

  def after_fail
    active_containers.each(&:disable!)
  end

  def clean
    active_containers.each(&:disable!)
    UffizziCore::Deployment::DeleteJob.perform_async(id)
  end
end
