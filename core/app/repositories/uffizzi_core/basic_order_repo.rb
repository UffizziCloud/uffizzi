# frozen_string_literal: true

module UffizziCore::BasicOrderRepo
  extend ActiveSupport::Concern

  included do
    scope :order_by_id, ->(order = :asc) {
      order(id: order)
    }
  end
end
