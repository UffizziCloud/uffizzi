class RemoveProjectRefFromSecrets < ActiveRecord::Migration[6.1]
  def change
    remove_reference :uffizzi_core_secrets, :project
  end
end
