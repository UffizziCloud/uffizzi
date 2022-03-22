# frozen_string_literal: true

class AddNameToContainer < ActiveRecord::Migration[6.1]
  def change
    add_column :uffizzi_core_containers, :name, :string
  end
end
