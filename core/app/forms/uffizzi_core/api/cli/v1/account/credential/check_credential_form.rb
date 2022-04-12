# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Account::Credential::CheckCredentialForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

  attribute :type
  attribute :account

  validate :credential_exists?

  private

  def credential_exists?
    errors.add(:type, :exist) if account.credentials.by_type(type).exists?
  end
end
