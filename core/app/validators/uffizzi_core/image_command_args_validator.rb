# frozen_string_literal: true

class UffizziCore::ImageCommandArgsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, command_args)
    record.errors.add(attribute, :invalid) if !command_args.nil? && !valid_command_args?(command_args)
  end

  def valid_command_args?(raw_command_args)
    return true if raw_command_args.empty?

    begin
      command_args = JSON.parse(raw_command_args)
    rescue JSON::ParserError
      return false
    end

    return false if command_args.class != Array || command_args.empty?

    command_args.all? { |item| item.instance_of?(String) }
  end
end
