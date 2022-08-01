# frozen_string_literal: true

class UffizziCore::AccountService
  class << self
    def create_credential(credential)
      UffizziCore::Deployment.active_for_credential_id(credential.id).pluck(:id).each do |deployment_id|
        UffizziCore::Deployment::CreateCredentialJob.perform_async(deployment_id, credential.id)
      end
    end

    def update_credential(credential)
      UffizziCore::Deployment.active_for_credential_id(credential.id).pluck(:id).each do |deployment_id|
        UffizziCore::Deployment::UpdateCredentialJob.perform_async(deployment_id, credential.id)
      end
    end

    def delete_credential(credential)
      UffizziCore::Deployment.active_for_credential_id(credential.id).pluck(:id).each do |deployment_id|
        UffizziCore::Deployment::DeleteCredentialJob.perform_async(deployment_id, credential.id)
      end
    end
  end
end
