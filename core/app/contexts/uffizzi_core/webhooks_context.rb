# frozen_string_literal: true

class UffizziCore::WebhooksContext
  attr_reader :request

  def initialize(request)
    @request = request
  end
end
