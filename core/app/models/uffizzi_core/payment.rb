# frozen_string_literal: true

class UffizziCore::Payment < UffizziCore::ApplicationRecord
  self.table_name = Rails.application.config.uffizzi_core[:table_names][:payments]

  belongs_to :account

  scope :succeeded, -> { where(status: :succeeded) }
  scope :pending, -> { where(status: :pending) }
  scope :failed, -> { where(status: :failed) }
end
