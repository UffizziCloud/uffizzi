# frozen_string_literal: true

# @model Container
#
# @property id [integer]
# @property name [string]
# @property memory_limit [integer]
# @property memory_request [integer]
# @property continuously_deploy [string]
# @property variables [object]
# @property secret_variables [object]
# @property container_config_files [ConfigFile]

class UffizziCore::Container < UffizziCore::ApplicationRecord
  include UffizziCore::ContainerRepo
  include AASM
  include UffizziCore::StateMachineConcern
  extend Enumerize

  self.table_name = UffizziCore.table_names[:containers]

  enumerize :kind, in: [:internal, :user], predicates: true

  belongs_to :deployment, touch: true
  belongs_to :repo, optional: true

  has_many :activity_items, dependent: :destroy
  has_many :container_config_files, dependent: :destroy
  has_many :config_files, through: :container_config_files

  attribute :public, :boolean, default: false
  attribute :port, :integer, default: nil

  enumerize :source, in: [:github], skip_validations: true
  validates :port,
            presence: true,
            inclusion: { in: 0..65_535 },
            uniqueness: { scope: :deployment_id },
            if: :should_check_port

  after_commit :check_target_port, on: :create

  before_save :update_target_port_value, if: :will_save_change_to_port?
  before_create :set_defaults

  accepts_nested_attributes_for :repo
  accepts_nested_attributes_for :container_config_files, allow_destroy: true

  validates :variables, 'uffizzi_core/environment_variable_list': true, allow_nil: true
  validates :secret_variables, 'uffizzi_core/environment_variable_list': true, allow_nil: true
  validates :entrypoint, 'uffizzi_core/image_command_args': true, allow_nil: true
  validates :command, 'uffizzi_core/image_command_args': true, allow_nil: true
  validates :tag, presence: true

  aasm :continuously_deploy, column: :continuously_deploy do
    state :disabled, initial: true
    state :enabled
  end

  aasm :state, column: :state do
    state :active, initial: true
    state :disabled

    event :activate do
      transitions from: [:disabled], to: :active
    end

    event :disable, after: :clean do
      transitions from: [:active], to: :disabled
    end
  end

  def image_name
    "#{image}:#{tag}"
  end

  private

  def should_check_port
    public && active?
  end

  def clean
    update(public: false, port: nil)
  end

  def set_defaults
    update_target_port_value
  end

  def update_target_port_value
    self.target_port = UffizziCore::ContainerService.target_port_value(self)
  end

  def check_target_port
    if target_port && deployment.containers.where(target_port: target_port).size > 1
      update(target_port: UffizziCore::DeploymentService.find_unused_port(deployment))
    end
  end
end
