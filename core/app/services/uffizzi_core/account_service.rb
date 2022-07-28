# frozen_string_literal: true

class UffizziCore::AccountService
  class << self
    def create_credential(credentials)
      UffizziCore::Deployment.active_for_credentials_id(credentials.id).pluck(:id).each do |deployment_id|
        UffizziCore::Deployment::CreateCredentialJob.perform_async(deployment_id, credentials.id)
      end
    end

    def update_credentials(credentials)
      UffizziCore::Deployment.active_for_credentials_id(credentials.id).pluck(:id).each do |deployment_id|
        UffizziCore::Deployment::UpdateCredentialsJob.perform_async(deployment_id, credentials.id)
      end
    end

    def delete_credential(credentials)
      UffizziCore::Deployment.active_for_credentials_id(credentials.id).pluck(:id).each do |deployment_id|
        UffizziCore::Deployment::DeleteCredentialJob.perform_async(deployment_id, credentials.id)
      end
    end
  end
end
