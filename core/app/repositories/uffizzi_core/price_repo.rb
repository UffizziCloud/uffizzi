# frozen_string_literal: true

module UffizziCore::PriceRepo
  extend ActiveSupport::Concern

  class_methods do
    def container_memory_for(env)
      find_by(slug: env.kind)
    end
  end
end
