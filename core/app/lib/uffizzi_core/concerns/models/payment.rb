# frozen_string_literal: true

module UffizziCore::Concerns::Models::Payment
  extend ActiveSupport::Concern

  included do
    self.table_name = UffizziCore.table_names[:payments]

    belongs_to :account

    scope :succeeded, -> { where(status: :succeeded) }
    scope :pending, -> { where(status: :pending) }
    scope :failed, -> { where(status: :failed) }
  end
end
