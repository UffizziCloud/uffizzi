# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Project::DeleteSecretForm < UffizziCore::Project
  include UffizziCore::ApplicationForm

  attr_accessor :secret

  permit secrets: [:name, :value]

  validate :check_existence

  def delete_secret!
    existing_secrets = secrets.presence || []

    self.secrets = existing_secrets.reject { |existing_secret| existing_secret['name'] == secret.name }
  end

  private

  def check_existence
    existing_secrets = secrets.presence || []

    detected_secret = existing_secrets.detect { |existing_secret| existing_secret['name'] == secret.name }

    errors.add(:secret, :not_found, name: secret.name) if detected_secret.nil?
  end
end
