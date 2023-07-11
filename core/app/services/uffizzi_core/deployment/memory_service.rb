# frozen_string_literal: true

class UffizziCore::Deployment::MemoryService
  class << self
    def valid_containers_memory_limit?(_total_memory_limit)
      true
    end

    def valid_containers_memory_request?(_total_requested_memory)
      true
    end
  end
end
