# frozen_string_literal: true

class UffizziCore::Account::UpdateCredentialsJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :accounts, retry: 5

  def perform(id)
    credentials = UffizziCore::Credential.find(id)
    UffizziCore::AccountService.update_credentials(credentials)
  end
end
