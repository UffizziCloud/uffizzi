class CreateProjectSecrets < ActiveRecord::Migration[6.1]
  def change
    create_table :project_secrets do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
