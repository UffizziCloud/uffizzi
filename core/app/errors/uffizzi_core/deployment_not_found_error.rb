# frozen_string_literal: true

class UffizziCore::DeploymentNotFoundError < StandardError
  attr_reader :deployment_id

  def initialize(deployment_id)
    super
    @deployment_id = deployment_id
  end
end
