# frozen_string_literal: true

class UffizziCore::ContainerRegistryError < StandardError
  attr_reader :errors, :error_key

  def initialize(response)
    prepared_errors = prepare_errors(response[:body], response[:status])
    @error_key = UffizziCore::ComposeFile::ErrorsService::DOCKER_REGISTRY_CONTAINER_ERROR_KEY
    @errors = { @error_key => prepared_errors }

    super(prepared_errors.to_json)
  end

  private

  def prepare_errors(body, status)
    parsed_body = JSON.parse!(body.to_s)

    parsed_body.fetch('errors', parsed_body)
  rescue JSON::ParserError, TypeError
    msg = body.empty? ? I18n.t('registry.error', code: status) : body

    { message: msg }
  end
end
