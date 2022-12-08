# frozen_string_literal: true

class UffizziCore::ContainerRegistryError < Faraday::ClientError
  def initialize(exc, response = nil)
    exc_msg_and_response!(exc, response)
    super(prepare_message)
  end

  private

  def prepare_message
    response_body_ = response_body.empty? ? {} : JSON.parse(response_body, symbolize_names: true)
    errors = if response_body_.has_key?(:errors)
      convert_errors_array_to_object(response_body_[:errors])
    else
      { registry_error: [I18n.t('registry.error', code: response_status)] }
    end

    errors.to_json
  end

  def convert_errors_array_to_object(array)
    array.reduce({}) { |acc, error| acc.merge(error[:code] => [error[:message], error[:detail].to_json]) }
  end
end
