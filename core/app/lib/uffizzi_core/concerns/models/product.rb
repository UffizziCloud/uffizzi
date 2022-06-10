# frozen_string_literal: true

module UffizziCore::Concerns::Models::Product
  extend ActiveSupport::Concern

  included do
    include UffizziCore::ProductRepo

    self.table_name = UffizziCore.table_names[:products]

    has_one :price, dependent: :destroy

    UffizziCore::Product.inheritance_column = :sti
  end
end
