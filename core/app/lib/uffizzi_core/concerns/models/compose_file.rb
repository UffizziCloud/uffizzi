# frozen_string_literal: true

module UffizziCore::Concerns::Models::ComposeFile
  extend ActiveSupport::Concern

  LOCAL_SOURCE = :local

  included do
    include UffizziCore::ComposeFileRepo
    include AASM
    extend Enumerize

    self.table_name = UffizziCore.table_names[:compose_files]

    belongs_to :project
    belongs_to :added_by, class_name: UffizziCore::User.name, foreign_key: :added_by_id, optional: true

    has_one :template, dependent: :destroy
    has_many :config_files, dependent: :destroy
    has_many :host_volume_files, dependent: :destroy
    has_many :deployments, dependent: :nullify

    enumerize :kind, in: UffizziCore.compose_file_kinds, predicates: true, scope: :shallow, default: :main

    validates :source, presence: true
    validate :main_compose_file_uniqueness, on: :create, if: -> { kind.main? }

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

    def local_source?
      repository_id.nil? && branch.nil?
    end

    def source_kind
      return LOCAL_SOURCE if local_source?
    end

    private

    def main_compose_file_uniqueness
      return unless project.compose_files.main.exists?

      errors.add(:compose_file, 'A compose file already exist for this project')
    end
  end
end
