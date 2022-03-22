# frozen_string_literal: true

class UffizziCore::EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEXP = /\A([^@\s<>]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  def validate_each(record, attribute, value)
    record.errors.add(attribute, (options[:message] || :invalid)) unless value&.match?(EMAIL_REGEXP)
  end
end
