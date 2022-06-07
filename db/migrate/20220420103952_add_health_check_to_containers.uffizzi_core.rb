# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20220419074956)

class AddHealthCheckToContainers < ActiveRecord::Migration[6.1]
  def change
    add_column :uffizzi_core_containers, :healthcheck, :jsonb
  end
end
