# frozen_string_literal: true

class UffizziCore::Deployment::MemoryService
  class << self
    def valid_memory_limit?(_deployment)
      true
    end

    def memory_limit_error_message(_deployment); end
  end
end
