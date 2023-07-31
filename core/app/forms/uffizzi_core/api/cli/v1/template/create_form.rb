# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Template::CreateForm < UffizziCore::Template
  include UffizziCore::DependencyInjectionConcern

  validate :check_max_memory_limit

  def check_max_memory_limit
    return if template_memory_module.valid_memory_limit?(self)

    message = template_memory_module.memory_limit_error_message(self)
    errors.add(:payload, message)
  end
end
