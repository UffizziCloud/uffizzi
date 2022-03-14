# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Account::Credential::CreateForm < UffizziCore::Credential
  include UffizziCore::ApplicationForm

  permit :type, :registry_url, :username, :password

  validate :check_registry_url
  validate :check_credential_correctness
  validate :credential_exists?

  private

  def check_credential_correctness
    errors.add(:username, :incorrect) unless UffizziCore::CredentialService.correct_credentials?(self)
  end

  def check_registry_url
    errors.add(:registry_url, :invalid_scheme) if URI.parse(registry_url).scheme.nil?
  end

  def credential_exists?
    errors.add(:type, :exist) if account.credentials.where(type: type).exists?
  end
end
