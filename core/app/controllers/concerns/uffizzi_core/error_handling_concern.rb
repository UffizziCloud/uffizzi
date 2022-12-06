# frozen_string_literal: true

module UffizziCore::ErrorHandlingConcern
  private

  def handle_container_registry_client_error(exception)
    response_body = exception.response[:body].empty? ? {} : JSON.parse(exception.response[:body], symbolize_names: true)
    errors = if response_body.has_key?(:errors)
      convert_errors_array_to_object(response_body[:errors])
    else
      { registry_error: [I18n.t('registry.error', code: exception.response[:status])] }
    end

    render json: { errors: errors }, status: :unprocessable_entity
  end

  def convert_errors_array_to_object(array)
    array.reduce({}) { |acc, error| acc.merge(error[:code] => [error[:message], error[:detail].to_json]) }
  end
end
