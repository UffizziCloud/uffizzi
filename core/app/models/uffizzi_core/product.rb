# frozen_string_literal: true

class UffizziCore::Product < UffizziCore::ApplicationRecord
  include UffizziCore::ProductRepo

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:products]

  has_one :price, dependent: :destroy

  UffizziCore::Product.inheritance_column = :sti
end
