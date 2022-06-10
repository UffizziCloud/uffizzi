# frozen_string_literal: true

module UffizziCore::Concerns::Models::Rating
  extend ActiveSupport::Concern

  included do
    include AASM

    self.table_name = UffizziCore.table_names[:ratings]

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
end
