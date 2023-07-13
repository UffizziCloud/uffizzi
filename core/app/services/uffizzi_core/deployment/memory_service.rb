# frozen_string_literal: true

class UffizziCore::Deployment::MemoryService
  class << self
    def valid_memory_limit?(_deployment)
      true
    end

    def valid_memory_request?(_deployment)
      true
    end

    def memory_limit_error_message(_deployment); end

    def memory_request_error_message(_deployment); end
  end
end
