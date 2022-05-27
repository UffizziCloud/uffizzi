# frozen_string_literal: true

class RenameNameToUffizziContainers < ActiveRecord::Migration[6.1]
  def change
    rename_column(:uffizzi_core_containers, :name, :service_name)
  end
end
