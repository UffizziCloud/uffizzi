# frozen_string_literal: true

class UffizziCore::DeploymentStateError < StandardError
  attr_reader :state

  def initialize(state)
    super
    @state = state
  end
end
