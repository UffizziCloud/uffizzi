# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ProjectSerializer < UffizziCore::BaseSerializer
  type :project
  has_many :deployments
  has_one :default_compose

  attributes :name,
             :slug,
             :description,
             :created_at,
             :secrets,


  def default_compose
    object.compose_files.main.first
  end

  def secrets
    return [] unless object.secrets
  
    object.secrets.map(&:name)
  end
end
