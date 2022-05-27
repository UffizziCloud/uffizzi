# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20220525113412)

class RenameNameToUffizziContainers < ActiveRecord::Migration[6.1]
  def change
    rename_column(:uffizzi_core_containers, :name, :service_name)
  end
end
