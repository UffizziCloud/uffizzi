# frozen_string_literal: true

class UffizziCore::Template::MemoryService
  class << self
    def valid_memory_limit?(_template)
      true
    end

    def valid_memory_request?(_template)
      true
    end

    def memory_limit_error_message(_template); end

    def memory_request_error_message(_template); end
  end
end
