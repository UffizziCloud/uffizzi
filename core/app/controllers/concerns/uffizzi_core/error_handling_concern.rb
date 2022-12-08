# frozen_string_literal: true

module UffizziCore::ErrorHandlingConcern
  private

  def handle_container_registry_client_error(exception)
    render json: { errors: JSON.parse(exception.message) }, status: :unprocessable_entity
  end
end
