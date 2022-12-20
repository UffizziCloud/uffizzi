# frozen_string_literal: true

module UffizziCore::FormUtils
  def fill_errors_with_json_from_error_message(error_message)
    JSON.parse(error_message).each { |key, value| errors.add(key, value) }
  end
end
