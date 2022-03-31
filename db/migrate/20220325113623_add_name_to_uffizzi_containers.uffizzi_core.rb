# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20220325113342)
class AddNameToUffizziContainers < ActiveRecord::Migration[6.1]
  def change
    add_column :uffizzi_core_containers, :name, :string
  end
end
