# frozen_string_literal: true

# @model
# @property id [integer]
# @property source [string]
# @property path [string]
# @property content(required) [string]
# @property auto_deploy [boolean]
# @property state [string]
# @property payload [string]

class UffizziCore::ComposeFile < UffizziCore::ApplicationRecord
  include UffizziCore::ComposeFileRepo
  include AASM
  extend Enumerize

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:compose_files]

  belongs_to :project
  belongs_to :added_by, class_name: UffizziCore::User.name, foreign_key: :added_by_id, optional: true

  has_one :template, dependent: :destroy
  has_many :config_files, dependent: :destroy
  has_many :deployments, dependent: :nullify

  enumerize :kind, in: [:main, :temporary], predicates: true, scope: :shallow, default: :main

  validates :project, uniqueness: { scope: :project }, if: -> { kind.main? }
  validates :source, presence: true, uniqueness: { scope: :project }

  aasm(:auto_deploy) do
    state :disabled, initial: true
    state :enabled

    event :enable do
      transitions from: [:disabled], to: :enabled
    end

    event :disable do
      transitions from: [:enabled], to: :disabled
    end
  end

  aasm(:state) do
    state :valid_file, initial: true
    state :invalid_file

    event :set_valid do
      transitions from: [:invalid_file], to: :valid_file
    end

    event :set_invalid do
      transitions from: [:valid_file], to: :invalid_file
    end
  end
end
