# frozen_string_literal: true
# This migration comes from uffizzi_core (originally 20220329143241)

class RemoveProjectRefFromSecrets < ActiveRecord::Migration[6.1]
  def change
    remove_reference(:uffizzi_core_secrets, :project)
  end
end
