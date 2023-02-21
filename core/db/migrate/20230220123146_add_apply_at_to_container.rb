# frozen_string_literal: true

class AddApplyAtToContainer < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_containers, :apply_at, :datetime, precision: 6)
  end
end
