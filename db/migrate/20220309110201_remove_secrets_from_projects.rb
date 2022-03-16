class RemoveSecretsFromProjects < ActiveRecord::Migration[6.1]
  def change
    remove_column :projects, :secrets
  end
end
