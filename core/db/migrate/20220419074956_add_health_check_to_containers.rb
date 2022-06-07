# frozen_string_literal: true

class AddHealthCheckToContainers < ActiveRecord::Migration[6.1]
  def change
    add_column :uffizzi_core_containers, :healthcheck, :jsonb
  end
end
