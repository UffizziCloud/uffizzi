class RenameProjectSecretsToSecrets < ActiveRecord::Migration[6.1]
  def change
    rename_table :uffizzi_core_project_secrets, :uffizzi_core_secrets
  end
end
