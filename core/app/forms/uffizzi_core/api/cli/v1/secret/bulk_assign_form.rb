# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Secret::BulkAssignForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

  attribute :secrets, Array
  validate :check_duplicates

  def assign_secrets(new_secrets)
    return if new_secrets.blank?

    new_secrets.each do |new_secret|
      secret = UffizziCore::Secret.new(name: new_secret['name'], value: new_secret['value'])
      secrets.append(secret)
    end
  end

  private

  def check_duplicates
    duplicates = []
    groupped_secrets = secrets.group_by { |secret| secret['name'] }
    groupped_secrets.each_pair do |key, value|
      duplicates << key if value.size > 1
    end

    errors.add(:secrets, :duplicates_exist, secrets: duplicates.join(', ')) if duplicates.present?
  end
end
