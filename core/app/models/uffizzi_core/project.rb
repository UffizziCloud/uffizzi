# frozen_string_literal: true

class UffizziCore::Project < UffizziCore::ApplicationRecord
  include AASM
  include UffizziCore::StateMachineConcern
  include UffizziCore::ProjectRepo

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:projects]

  belongs_to :account

  has_many :repos
  has_many :deployments, dependent: :destroy
  has_many :user_projects, dependent: :destroy
  has_many :users, through: :user_projects
  has_many :invitations, as: :entityable
  has_many :config_files, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :credentials, through: :account
  has_many :compose_files, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :account }
  validates :secrets, 'uffizzi_core/environment_variable_list': true, allow_nil: true

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

  def any_paid_deployments?
    !all_deployments_free?
  end

  def all_deployments_free?
    active_deployments.all?(&:free?)
  end

  def after_disable
    update(name: "#{name} deleted #{DateTime.current.strftime('%H:%M:%S-%m%d%Y')}")
    update(slug: "#{slug} deleted #{DateTime.current.strftime('%H:%M:%S-%m%d%Y')}")
    disable_deployments
  end

  def active_deployments
    deployments.active
  end

  def disable_deployments
    active_deployments.each(&:disable!)
  end

  def compose_file
    compose_files.main.first
  end
end
