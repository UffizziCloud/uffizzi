# frozen_string_literal: true

class UpdateNameConstraintToProjects < ActiveRecord::Migration[6.1]
  def change
    remove_index(:uffizzi_core_projects, [:account_id, :name])
    add_index(:uffizzi_core_projects, [:account_id, :name], unique: true,
                                                            where: "state = 'active'",
                                                            name: 'proj_uniq_name')
  end
end
