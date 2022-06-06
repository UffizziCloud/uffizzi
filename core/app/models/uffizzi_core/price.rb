# frozen_string_literal: true

class UffizziCore::Price < UffizziCore::ApplicationRecord
  include UffizziCore::PriceRepo

  self.table_name = UffizziCore.table_names[:prices]

  belongs_to :product
end
