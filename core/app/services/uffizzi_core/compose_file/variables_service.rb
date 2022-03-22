# frozen_string_literal: true

module UffizziCore::ComposeFile::VariablesService
  def parse_variable_from_string(str)
    variable_parts = str.split('=', 2)

    parse_variable_from_array(variable_parts)
  end

  def parse_variable_from_array(arr)
    name = arr.first.to_s
    value = arr.last.to_s

    build_variable(name, value)
  end

  def build_variable(name, value)
    raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.no_variable_name', name: name, value: value) if name.blank?

    {
      name: name,
      value: value,
    }
  end
end
