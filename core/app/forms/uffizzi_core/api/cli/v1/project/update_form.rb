# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Project::UpdateForm < UffizziCore::Project
  include UffizziCore::ApplicationForm
  MAX_SECRET_KEY_LENGTH = 256

  permit :name, :slug, :description

  validates :name, presence: true, uniqueness: { scope: :account }
  validates :slug, presence: true, uniqueness: true

  validate :check_duplicates
  validate :check_length

  def assign_secrets(new_secrets)
    return if new_secrets.blank?

    new_secrets.each do |new_secret|
      secrets.build({ name: new_secret['name'], value: new_secret['value'] })
    end
  end

  private

  def check_duplicates
    duplicates = []
    groupped_secrets = secrets.group_by { |secret| secret['name'] }
    groupped_secrets.each_pair do |key, value|
      duplicates << key if value.size > 1
    end

    error_message = I18n.t('secrets.duplicates_exists', secrets: duplicates.join(', '))
    errors.add(:secrets, error_message) if duplicates.present?
  end

  def check_length
    secrets_with_invalid_key_length = secrets.select { |secret| secret['name'].length > MAX_SECRET_KEY_LENGTH }

    error_message = I18n.t('secrets.invalid_key_length')
    errors.add(:secrets, error_message) if secrets_with_invalid_key_length.present?
  end
end
