# frozen_string_literal: true

module UffizziCore::ProductRepo
  extend ActiveSupport::Concern

  class_methods do
    def container_memory
      find_by(slug: :container_memory)
    end
  end
end
