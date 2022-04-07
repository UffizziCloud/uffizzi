# frozen_string_literal: true

class AddHealthcheckColumnToContainers < ActiveRecord::Migration[6.1]
  def change
    add_column :uffizzi_core_containers, :healthcheck, :jsonb
  end
end