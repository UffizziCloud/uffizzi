# frozen_string_literal: true

class UffizziCore::Rating < UffizziCore::ApplicationRecord
  include AASM

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:ratings]

  aasm(:state) do
    state :active, initial: true
    state :disabled

    event :activate do
      transitions from: [:disabled], to: :active
    end

    event :disable do
      transitions from: [:active], to: :disabled
    end
  end
end
