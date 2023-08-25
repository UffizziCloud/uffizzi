# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::DeploymentSerializer < UffizziCore::BaseSerializer
  include UffizziCore::DependencyInjectionConcern
  include_module_if_exists('UffizziCore::Api::Cli::V1::Projects::DeploymentSerializerModule')

  type :deployment

  attributes :id,
             :project_id,
             :state,
             :preview_url

  has_many :containers

  belongs_to :deployed_by

  def containers
    object.containers.active
  end
end
