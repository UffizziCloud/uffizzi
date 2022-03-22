# frozen_string_literal: true

class UffizziCore::EnvironmentVariableListValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, variables)
    record.errors.add(attribute, :invalid) if variables.class != Array || !valid_variables?(variables)
  end

  def valid_variables?(variables)
    variables.each do |variable|
      return false if variable.class != Hash || !variable.key?('name') || variable['name'].nil? || !variable.key?('value')
    end

    true
  end
end
