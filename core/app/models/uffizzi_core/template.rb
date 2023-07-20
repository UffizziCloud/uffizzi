# frozen_string_literal: true

class UffizziCore::Template < UffizziCore::ApplicationRecord
  include UffizziCore::Concerns::Models::Template
  include UffizziCore::DependencyInjectionConcern

  validate :check_max_memory_limit

  def check_max_memory_limit
    return if template_memory_module.valid_memory_limit?(self)

    message = template_memory_module.memory_limit_error_message(self)
    errors.add(:payload, message)
  end
end
