# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ProjectSerializer < UffizziCore::BaseSerializer
  type :project

  attributes :slug
end
