# frozen_string_literal: true

class AddLastDeployAtToDeployments < ActiveRecord::Migration[6.1]
  def up
    add_column :uffizzi_core_deployments, :last_deploy_at, :datetime

    UffizziCore::Deployment.where(last_deploy_at: nil).update_all('last_deploy_at = updated_at')
  end

  def down
    remove_column :uffizzi_core_deployments, :last_deploy_at
  end
end
