# frozen_string_literal: true

class UffizziCore::CiService
  class << self
    def valid_request_from_ci_workflow?(_params)
      false
    end
  end
end
