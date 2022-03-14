# frozen_string_literal: true

class UffizziCore::Account::CreateCredentialJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :accounts, retry: 5

  def perform(id)
    credential = UffizziCore::Credential.find(id)
    UffizziCore::AccountService.create_credential(credential)
  end
end
