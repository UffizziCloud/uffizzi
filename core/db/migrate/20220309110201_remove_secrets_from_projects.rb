# frozen_string_literal: true

class RemoveSecretsFromProjects < ActiveRecord::Migration[6.1]
  def change
    remove_column('uffizzi_core_projects', 'secrets')
  end
end
