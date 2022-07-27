# frozen_string_literal: true

class UffizziCore::AccountService
  class << self
    def create_credential(credential)
      credential.account.projects.active.each do |project|
        project.deployments.active.each do |deployment|
          UffizziCore::Deployment::CreateCredentialJob.perform_async(deployment.id, credential.id)
        end
      end
    end

    def update_credentials(credentials)
      credentials.account.projects.active.each do |project|
        project.deployments.active.each do |deployment|
          UffizziCore::Deployment::UpdateCredentialsJob.perform_async(deployment.id, credentials.id)
        end
      end
    end

    def delete_credential(credential)
      credential.account.projects.active.each do |project|
        project.deployments.active.each do |deployment|
          UffizziCore::Deployment::DeleteCredentialJob.perform_async(deployment.id, credential.id)
        end
      end
    end
  end
end
