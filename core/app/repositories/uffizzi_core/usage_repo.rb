# frozen_string_literal: true

module UffizziCore::UsageRepo
  extend ActiveSupport::Concern

  included do
    scope :by_timestamp, ->(direction = :asc) { order("timestamp #{direction}") }
  end
end
