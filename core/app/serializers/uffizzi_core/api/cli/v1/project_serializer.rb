# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ProjectSerializer < UffizziCore::BaseSerializer
  type :project
  has_many :deployments
  has_many :secrets
  has_one :default_compose

  attributes :name,
             :slug,
             :description,
             :created_at

  def default_compose
    object.compose_files.main.first
  end

  def deployments
    object.deployments.active.map do |deployment|
      deployment.state = if UffizziCore::DeploymentService.failed?(deployment)
        UffizziCore::Deployment::STATE_FAILED
      else
        UffizziCore::Deployment::STATE_ACTIVE
      end
      deployment
    end
  end

  def secrets
    return [] unless object.secrets

    object.secrets.map(&:name)
  end
end
