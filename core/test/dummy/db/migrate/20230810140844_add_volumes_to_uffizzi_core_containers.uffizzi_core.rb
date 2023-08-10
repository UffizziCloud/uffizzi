# frozen_string_literal: true
# This migration comes from uffizzi_core (originally 20220422151523)

class AddVolumesToUffizziCoreContainers < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_containers, :volumes, :jsonb)
  end
end
