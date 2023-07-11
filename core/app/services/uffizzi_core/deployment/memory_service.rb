# frozen_string_literal: true

class UffizziCore::Deployment::MemoryService
  class << self
    def valid_containers_memory_limit?(_deployment)
      true
    end

    def valid_containers_memory_request?(_deployment)
      true
    end
  end
end
