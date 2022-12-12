# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Template::CreateForm < UffizziCore::Template
  validate :check_max_memory_limit
  validate :check_max_memory_request

  private

  def check_max_memory_limit
    return if valid_containers_memory_limit?

    errors.add(:payload, :max_memory_limit_error, max: project.account.container_memory_limit)
  end

  def check_max_memory_request
    return if valid_containers_memory_request?

    errors.add(:payload, :max_memory_request_error, max: project.account.container_memory_limit)
  end
end
