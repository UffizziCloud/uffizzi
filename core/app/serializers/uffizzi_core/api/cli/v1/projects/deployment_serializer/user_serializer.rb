# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::DeploymentSerializer::UserSerializer < UffizziCore::BaseSerializer
  type :user

  attributes :id, :kind, :email

  def kind
    :internal
  end
end
