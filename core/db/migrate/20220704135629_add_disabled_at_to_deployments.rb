# frozen_string_literal: true

class AddDisabledAtToDeployments < ActiveRecord::Migration[6.1]
  def up
    change_table :uffizzi_core_deployments do |t|
      t.datetime :disabled_at
    end
    UffizziCore::Deployment.disabled.find_each do |deployment|
      deployment.update_attribute(:disabled_at, deployment.updated_at)
    end
  end

  def down
    change_table :uffizzi_core_deployments do |t|
      t.remove :disabled_at
    end
  end
end
