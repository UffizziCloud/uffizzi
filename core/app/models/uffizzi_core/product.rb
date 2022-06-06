# frozen_string_literal: true

class UffizziCore::Product < UffizziCore::ApplicationRecord
  include UffizziCore::ProductRepo

  self.table_name = UffizziCore.table_names[:products]

  has_one :price, dependent: :destroy

  UffizziCore::Product.inheritance_column = :sti
end
