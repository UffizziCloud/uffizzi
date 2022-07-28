# frozen_string_literal: true

class UffizziCore::Account::UpdateCredentialJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :accounts, retry: 5

  def perform(id)
    credential = UffizziCore::Credential.find(id)
    UffizziCore::AccountService.update_credential(credential)
  end
end
