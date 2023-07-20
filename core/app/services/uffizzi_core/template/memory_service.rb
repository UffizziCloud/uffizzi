# frozen_string_literal: true

class UffizziCore::Template::MemoryService
  class << self
    def valid_memory_limit?(_template)
      true
    end

    def memory_limit_error_message(_template); end
  end
end
