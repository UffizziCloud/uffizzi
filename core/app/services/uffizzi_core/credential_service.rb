# frozen_string_literal: true

class UffizziCore::CredentialService
  class << self
    def correct_credentials?(credential)
      status = case credential.type
               when UffizziCore::Credential::DockerHub.name
                 UffizziCore::DockerHub::CredentialService.credential_correct?(credential)
               when UffizziCore::Credential::GithubContainerRegistry.name
                 UffizziCore::GithubContainerRegistry::CredentialService.credential_correct?(credential)
               when UffizziCore::Credential::Azure.name
                 UffizziCore::Azure::CredentialService.credential_correct?(credential)
               when UffizziCore::Credential::Google.name
                 UffizziCore::Google::CredentialService.credential_correct?(credential)
               when UffizziCore::Credential::Amazon.name
                 UffizziCore::Amazon::CredentialService.credential_correct?(credential)
               else
                 false
      end

      if credential.persisted? && credential.active? && !status
        Rails.logger.warn("Wrong credential: credential_correct? credential_id=#{credential.id}")
      end

      status
    end

    def update_expired_credentials
      currect_date = DateTime.now
      credentials = UffizziCore::Credential::Amazon.active.where('updated_at < ?', currect_date - 10.hours)

      credentials.each do |credential|
        deployments = UffizziCore::Deployment.where(project_id: credential.account.projects.select(:id)).with_amazon_repos

        deployments.each do |deployment|
          UffizziCore::Deployment::CreateCredentialJob.perform_async(deployment.id, credential.id)
        end

        credential.update(updated_at: currect_date)
      end
    end
  end
end
