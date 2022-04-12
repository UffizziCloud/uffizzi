class AddResourceToSecrets < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :uffizzi_core_secrets, :resource, polymorphic: true
  end
end
