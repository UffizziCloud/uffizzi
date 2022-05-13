# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20220309110201)

class RemoveSecretsFromProjects < ActiveRecord::Migration[6.1]
  def change
    remove_column('uffizzi_core_projects', 'secrets')
  end
end
