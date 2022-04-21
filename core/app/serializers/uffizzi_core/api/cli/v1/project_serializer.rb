# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ProjectSerializer < UffizziCore::BaseSerializer
  type :project
  has_many :deployments

  attributes :name,
             :slug,
             :description,
             :created_at,
             :secrets,
             :default_compose

  private
  
  def default_compose
    compose_file = object.compose_files.main.first

    UffizziCore::Api::Cli::V1::ProjectSerializer::ComposeFileSerializer.new(compose_file).as_json
  end

  def secrets
    object.secrets.map{ |secret| secret.name }
  end
end
