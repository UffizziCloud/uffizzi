# frozen_string_literal: true

class AddVolumesToUffizziCoreContainers < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_containers, :volumes, :jsonb)
  end
end
