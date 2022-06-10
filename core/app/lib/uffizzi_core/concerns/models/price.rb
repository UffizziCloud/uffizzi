# frozen_string_literal: true

module UffizziCore::Concerns::Models::Price
  extend ActiveSupport::Concern

  included do
    include UffizziCore::PriceRepo

    self.table_name = UffizziCore.table_names[:prices]

    belongs_to :product
  end
end
