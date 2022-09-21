# frozen_string_literal: true

class UffizziCore::ComposeFile::ContainerService
  class << self
    def has_secret?(container, secret)
      container['secret_variables'].any? { |container_secret| container_secret['name'] == secret['name'] }
    end

    def update_secret(container, secret)
      secret_index = container['secret_variables'].find_index { |container_secret| container_secret['name'] == secret['name'] }
      container['secret_variables'][secret_index] = secret

      container
    end
  end
end
