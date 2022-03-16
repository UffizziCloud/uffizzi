class CreateProjectSecrets < ActiveRecord::Migration[6.1]
  def change
    create_table('uffizzi_core_project_secrets', force: :cascade) do |t|
      t.bigint('project_id', null: false)
      t.string('name')
      t.string('value')
      t.datetime('created_at', precision: 6, null: false)
      t.datetime('updated_at', precision: 6, null: false)
      t.index(['project_id'], name: 'index_project_secrets_on_project_id')
    end
  end
end
