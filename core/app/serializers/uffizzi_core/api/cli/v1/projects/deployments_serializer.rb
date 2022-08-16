# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::DeploymentsSerializer < UffizziCore::BaseSerializer
  type :deployment

  attributes :id,
             :created_at,
             :updated_at,
             :state,
             :preview_url,
             :metadata

  belongs_to :deployed_by

  def deployed_by
    object.deployed_by
  end
end
